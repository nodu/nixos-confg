final: prev: {
  sddm = prev.sddm.overrideAttrs (old: rec {
    # pname = old.pname + "-unstable";
    # how to do this at the overlay level? ie, I don't want to have to call in homemanager
    pname = old.pname;
    version = "2023-05-12";
    src = prev.pkgs.fetchFromGitHub {
      owner = "sddm";
      repo = "sddm";
      rev = "58a35178b75aada974088350f9b89db45f5c3800";
      sha256 = "sha256-lTfsMUnYu3E2L25FSrMDkh9gB5X2fC0a5rvpMnPph4k=";
    };
    patches = with prev.lib; filter (x: hasSuffix "sddm-ignore-config-mtime.patch" x) old.patches;

    # patches = pkgs.lib.filter (x: pkgs.lib.hasSuffix "sddm-ignore-config-mtime.patch" x) old.patches;

    nativeBuildInputs = old.nativeBuildInputs ++ [ prev.pkgs.docutils ];

    cmakeFlags = old.cmakeFlags ++ [
      "-DBUILD_MAN_PAGES=ON"
      "-DSYSTEMD_TMPFILES_DIR=${placeholder "out"}/etc/tmpfiles.d"
      "-DSYSTEMD_SYSUSERS_DIR=${placeholder "out"}/lib/sysusers.d"
    ];

    outputs = (old.outputs or [ "out" ]) ++ [ "man" ];
  });
}
