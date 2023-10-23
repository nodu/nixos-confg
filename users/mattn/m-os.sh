# My m. OS shortcuts

#TODO Notes
alias t='cd ~/repos/todo && v todo.md && cd -'
alias tdb='v ~/repos/todo/backlog.md'

tda() { # 'ta * new note to add'
	# Add to beginning of file
	# sed -i "1i$1" ~/repos/todo/todo.md
	# sed -i -e "$a $1" ~/repos/todo/todo.md
	echo "- [ ] $1" >>~/repos/todo/backlog.md
}

tdpull() { # pull todo
	cd ~/repos/todo || exit
	git pull
	cd - || exit
}

tdpush() { # diff/upload todo.md
	cd ~/repos/todo || exit
	git push origin master
	cd - || exit
}

tdcommit() { #commit todos
	cd ~/repos/todo || exit
	git diff todo.md
	git add todo.md
	git commit -m "Update Todo $(date)"
	cd - || exit
}

tddiff() { # diff todo.md
	cd ~/repos/todo || exit
	git diff todo.md
	cd - || exit
}

tdcleanup() {
	cd ~/repos/todo || exit
	grep "\- \[x\]" todo.md >>done.md
	grep "\- \[n\]" todo.md >>no.md
	sed -i -e '/- \[x]/ d' todo.md
	sed -i -e '/- \[n]/ d' todo.md

	grep "\- \[x\]" backlog.md >>done.md
	grep "\- \[n\]" backlog.md >>no.md
	sed -i -e '/- \[x]/ d' backlog.md
	sed -i -e '/- \[n]/ d' backlog.md
	cd - || exit
}

m.function-definition() {
	declare -f "$1"
}

m.function-where() {
	type -a "$1"
}

m.git-quickcommit() {
	git status
	git diff
	git commit -m "Update"
	git push
}
m.git-quickcommit-all() {
	git status
	git diff
	#pause()
	#read -p 'Press any key to continue...'
	git add -A :/
	git commit -m "Update"
	git push
}

m.gpg-encrypt-sign() {
	gpg --encrypt --sign -r "$1" "$2"
}
m.gpg-encrypt() {
	gpg --symmetric "$1"
}
m.gpg-decrypt() {
	gpg --decrypt "$1"
}

m.base64-decode() {
	echo -n "$1" | base64 -d
}

m.base64-encode() {
	echo -n "$1" | base64
}

m.time-global() {
	echo 'Current:          ' "$(date)"
	echo 'UTC:              ' "$(date -u)"
	echo '              '
	echo 'Los Angeles (-7): ' $(TZ='America/Los_Angeles' date)
	echo 'Chicago: (-5)     ' $(TZ='America/Chicago' date)
	echo 'London: (+1)      ' $(TZ='Europe/London' date)
	echo 'Hong Kong: (+8)   ' $(TZ='Asia/Hong_Kong' date)
}

alias m.time-zones='timedatectl list-timezones --no-pager'
m.time-meet() {
	#!/usr/bin/env bash
	# ./meet.sh || meet.sh 09/22
	# ig20180122 - displays meeting options in other time zones
	# ml20220712 - Linux GNU date compatible
	# https://superuser.com/questions/164339/timezone-conversion-by-command-line
	# https://stackoverflow.com/questions/53075017/how-can-i-do-bash-arithmetic-with-variables-that-are-numbers-with-leading-zeroes
	# set the following variable to the start and end of your working day
	# start and end time, with one space
	daystart=8
	dayend=24
	# set the local TZ
	myplace='America/Los_Angeles'
	# set the most common places
	place[1]='America/Chicago'
	place[2]='Europe/London'
	place[3]='Asia/Hong_Kong'
	place[4]='Asia/Kolkata'
	# add cities using place[5], etc.
	# set the date format for search
	dfmt="%m/%d" # date format for meeting date
	# New format so It can be used as argument
	hfmt="+%B %e, %Y" # date format for the header
	# no need to change onwards
	format1="%-12s " # Increase if your cities names are long
	format2="%02d "
	mdate=$1
	if [[ "$1" == "" ]]; then mdate=$(date +"$dfmt"); fi
	# date -j -f "$dfmt" "$hfmt" "$mdate"
	date -d $mdate "$hfmt"                 # GNU linux compliant
	here=$(TZ=$myplace date -d $mdate +%z) # Same Here
	here=$(($(printf "%g" $here) / 100))
	printf "$format1" ${myplace/*\//} #"Here"
	printf "$format2" $(seq $daystart $dayend)
	printf "\n"
	for i in $(seq 1 "${#place[*]}"); do
		there=$(TZ=${place[$i]} date -d "$mdate" +%z) # same here
		there=$(($(printf "%g" $there) / 100))
		city[$i]=${place[$i]/*\//}
		tdiff[$i]=$(($there - $here))
		printf "$format1" ${city[$i]}
		for j in $(seq $daystart $dayend); do
			sub=$(($j + ${tdiff[$i]}))
			if [[ $sub -gt 24 ]]; then sub="$((sub - 24))"; fi
			#if [[ 10#$sub > 12 ]]; then sub="$((10#$sub-12))"; fi
			printf "$format2" $sub
		done
		printf "(%+d)\n" ${tdiff[$i]}
	done
}

m.time-overtime() {
	cd /tmp
	nix-shell -p nodejs --run "git clone https://github.com/diit/overtime-cli.git; \
  cd overtime-cli; \
  npm install; \
  node index.js show America/Los_Angeles America/Chicago Asia/Hong_Kong Europe/London; \
  exit; \
  "
	cd -
}

m.time-time.is() {
	firefox "https://time.is/900AM_4_Feb_2023_in_HKT/Kolkata/GMT/London/San_Francisco"
}
m.time-time.is-table() {
	firefox "https://time.is/compare/900AM_4_Feb_2023_in_HKT/Kolkata/GMT/London/San_Francisco"
}

alias m.weather-sf='curl wttr.in/sanfrancisco\?u'
alias m.weather-chicago='curl wttr.in/chicago\?u'
alias m.weather-terralinda='curl wttr.in/94903\?u'
alias m.weather='curl wttr.in\?u'

alias m.whereami-latlong='curl ipinfo.io/loc'
alias m.whereami-country='curl ipinfo.io/country'
alias m.whereami='curl ipinfo.io/json'

alias m.vlcc='vlc -I ncurses'
alias m.vlcc-brain='vlc -I ncurses "/host/matt/My Drive/Audio/Brain.fm" --random'

alias m.source-alias="source ~/repos/sys/nixos-config/users/mattn/aliases"

alias m.edit-vim="v ~/repos/sys/nixos-config/users/mattn/vim-config.nix"
alias m.edit-alias="v ~/repos/sys/nixos-config/users/mattn/aliases"
alias m.edit-i3="v ~/repos/sys/nixos-config/users/mattn/i3"
alias m.edit-home-manager="nvim ~/repos/sys/nixos-config/users/mattn/home-manager.nix"

# -a = -rlptgoD; removed -po
# -p, --perms                 preserve permissions
# -o, --owner                 preserve owner (super-user only)
# -n --dry-run
# -del --delete-excluded
# --exclude 'file or dir'
# --info=progress2 try if too verbose also remove -v

alias m.cp-rsync="rsync --recursive --links --times --devices --specials --partial --human-readable --progress -v"
alias m.mv-rsync="rsync --recursive --links --times --devices --specials --partial --human-readable --progress -v --remove-source-files"

alias m.git-uncommit-last='git reset --soft HEAD~1'
alias m.git-unstage-file='git reset HEAD'

alias m.tldrf='tldr --list | fzf --preview "tldr {1} --color=always" --preview-window=right,70% | xargs tldr'

function m.ffmpeg-reduce() {
	ffmpeg -i "$1" -vcodec libx265 -crf 28 "$1_reduced.mp4"
}

function m.ff() {
	local file
	file=$(fzf --preview 'bat --style=numbers --color=always --line-range :500 {}')
	if [[ $file ]]; then
		$EDITOR "$file"
	else
		echo "cancelled m.ff"
	fi
}

function m.fc() {
	local file
	file=$(fzf --preview 'bat --style=numbers --color=always --line-range :500 {}')
	if [[ $file ]]; then
		cat "$file"
	else
		echo "cancelled m.ff"
	fi
}

function m.fd() {
	local dir
	dir=$(find ${1:-.} -type d 2>/dev/null | fzf +m) && cd "$dir"
	ls
}

function m.kill() {
	local pid
	pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

	if [ "x$pid" != "x" ]; then
		echo "$pid" | xargs kill -"${1:-9}"
	fi
}
function m.env() {
	local out
	out=$(env | fzf)
	echo "$(echo "$out" | cut -d= -f2)"
}
alias m.x='xrandr-auto'
alias sgpt='OPENAI_API_KEY=$(gpg --decrypt $HOME/.chatgpt-secret.txt.gpg 2>/dev/null) sgpt'

function m.list-alias-functions() {
	# TODO list full definitions, then only paste func name/alias to command line
	echo
	echo -e "\033[1;4;32m""Functions:""\033[0;34m"
	compgen -A function
	echo
	echo -e "\033[1;4;32m""Aliases:""\033[0;34m"
	compgen -A alias
	echo
	echo -e "\033[0m"
}

function m.show-def() {
	item=$1
	itemtype=$(whence -w "$item" | awk '{ print $2}')
	echo "Type: $itemtype"
	if [ "$itemtype" = "alias" ]; then
		alias "$1"
	else
		declare -f "$1"
	fi
}
function m() {
	print -z -- "$(m.list-alias-functions | fzf --preview "source ~/repos/sys/nixos-config/users/mattn/aliases > /dev/null 2>&1; $HOME/.config/fzf-m-os-preview-function.sh {1}")"
}

function m2() {
	CMD=$(
		(
			(alias)
			(functions | grep "()" | cut -d ' ' -f1 | grep -v "^_")
		) | fzf | cut -d '=' -f1
	)

	eval "$CMD"
}
