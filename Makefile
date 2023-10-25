# Connectivity info for Linux VM
#export NIXADDR=192.168.0.175
NIXADDR ?= unset
NIXPORT ?= 22
NIXUSER ?= mattn

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# The name of the nixosConfiguration in the flake
# MRNOTE not vm-intel, fully arm
#NIXNAME ?= vm-intel
NIXNAME ?= vm-aarch64

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

switch:
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${NIXNAME}"

test:
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild test --flake ".#$(NIXNAME)"

list:
	sudo nix-env --list-generations -p /nix/var/nix/profiles/system

clean:
	sudo nix-collect-garbage

clean-generations:
	sudo nix-collect-garbage --delete-older-than 30d

optimize:
	nix-store --optimise

#https://www.reddit.com/r/NixOS/comments/10107km/how_to_delete_old_generations_on_nixos/
switch-to-boot-to-clean-boot-partition:
	sudo /run/current-system/bin/switch-to-configuration boot

set-current:
	sudo nix-env -p /nix/var/nix/profiles/system --switch-generation $(gen)

# This builds the given NixOS configuration and pushes the results to the
# cache. This does not alter the current running system. This requires
# cachix authentication to be configured out of band.
cache:
	nix build '.#nixosConfigurations.$(NIXNAME).config.system.build.toplevel' --json \
		| jq -r '.[].outputs | to_entries[].value' \
		| cachix push mitchellh-nixos-config
		#| cachix push os

# bootstrap a brand new VM. The VM should have NixOS ISO on the CD drive
# and just set the password of the root user to "root". This will install
# NixOS. After installing NixOS, you must reboot and set the root password
# for the next step.
#
# NOTE(mitchellh): I'm sure there is a way to do this and bootstrap all
# in one step but when I tried to merge them I got errors. One day.
vm/bootstrap0:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		parted /dev/sda -- mklabel gpt; \
		parted /dev/sda -- mkpart primary 512MB -8GB; \
		parted /dev/sda -- mkpart primary linux-swap -8GB 100\%; \
		parted /dev/sda -- mkpart ESP fat32 1MB 512MB; \
		parted /dev/sda -- set 3 esp on; \
		sleep 1; \
		mkfs.ext4 -L nixos /dev/sda1; \
		mkswap -L swap /dev/sda2; \
		mkfs.fat -F 32 -n boot /dev/sda3; \
		sleep 1; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount /dev/disk/by-label/boot /mnt/boot; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a \
			nix.package = pkgs.nixUnstable;\n \
			nix.extraOptions = \"experimental-features = nix-command flakes\";\n \
			nix.settings.substituters = [\"https://mitchellh-nixos-config.cachix.org\"];\n \
			nix.settings.trusted-public-keys = [\"mitchellh-nixos-config.cachix.org-1:bjEbXJyLrL1HZZHBbO4QALnI5faYZppzkU4D2s0G8RQ=\"];\n \
  			services.openssh.enable = true;\n \
			services.openssh.settings.PasswordAuthentication = true;\n \
			services.openssh.settings.PermitRootLogin = \"yes\";\n \
			users.users.root.initialPassword = \"root\";\n \
		' /mnt/etc/nixos/configuration.nix; \
                nixos-install --no-root-passwd && reboot; \
	"
			# Maybe needed on fresh build:
			# nix.settings.substituters = [\"https://mitchellh-nixos-config.cachix.org\"];\n \
			# nix.settings.trusted-public-keys = [\"mitchellh-nixos-config.cachix.org-1:bjEbXJyLrL1HZZHBbO4QALnI5faYZppzkU4D2s0G8RQ=\"];\n \

	# nix.binaryCaches = [\"https://os.cachix.org\"];\n \
	# 	nix.binaryCachePublicKeys = [\"os.cachix.org-1:RlKUKtqxLUZK10qAltMfjGrHw7ZkRMK/UOwvZ4Lsnrg=\"];\n \

# after bootstrap0, run this to finalize. After this, do everything else
# in the VM unless secrets change.
vm/bootstrap:
	NIXUSER=root $(MAKE) vm/copy
	NIXUSER=root $(MAKE) vm/switch
	$(MAKE) vm/secrets
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo reboot; \
	"

# copy our secrets into the VM
vm/secrets:
	# GPG keyring
	#rsync -av -e 'ssh $(SSH_OPTIONS)' \
	#	--exclude='.#*' \
	#	--exclude='S.*' \
	#	--exclude='*.conf' \
	#	$(HOME)/.gnupg/ $(NIXUSER)@$(NIXADDR):~/.gnupg
	# SSH keys
	# MRNOTE Added L as currently they're symlinks
	#rsync -avL -e 'ssh $(SSH_OPTIONS)' \
	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='environment' \
		$(HOME)/.ssh/ $(NIXUSER)@$(NIXADDR):~/.ssh

# copy the Nix configurations into the VM.
vm/copy:
	rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		--exclude='vendor/' \
		--exclude='.git/' \
		--exclude='.git-crypt/' \
		--exclude='iso/' \
		--rsync-path="sudo rsync" \
		$(MAKEFILE_DIR)/ $(NIXUSER)@$(NIXADDR):/nix-config

# have to run vm/copy before.
# run the nixos-rebuild switch command. This does NOT copy files so you
#if it complains about error upgrading system... use the --install-bootloader flag
#sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --install-bootloader --flake \"/nix-config#${NIXNAME}\" \

vm/switch:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake \"/nix-config#${NIXNAME}\" \
	"

# Build an ISO image
iso/nixos.iso:
	cd iso; ./build.sh
