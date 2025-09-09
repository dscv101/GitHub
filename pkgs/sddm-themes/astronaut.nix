{
  lib,
  stdenv,
  fetchFromGitHub,
  kdePackages,
  theme ? "astronaut",
}:
stdenv.mkDerivation rec {
  pname = "sddm-astronaut-theme";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Keyitdev";
    repo = "sddm-astronaut-theme";
    rev = "468a100460d5feaa701c2215c737b55789cba0fc";
    sha256 = "sha256-RVU29FGcWP0vQtU1zGlb8iP0HbCyOjJp2zAFLqarOWs=";
  };

  propagatedUserEnvPkgs = with kdePackages; [
    kconfig
    kcoreaddons
    kdeclarative
    kiconthemes
    kirigami
    plasma5support
    ksvg
    qt5compat
    qtdeclarative
    qtsvg
  ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/sddm/themes
    cp -aR $src $out/share/sddm/themes/${theme}
  '';

  postFixup = ''
    mkdir -p $out/nix-support

    echo ${kdePackages.kconfig} >> $out/nix-support/propagated-user-env-packages
    echo ${kdePackages.kcoreaddons} >> $out/nix-support/propagated-user-env-packages
    echo ${kdePackages.kdeclarative} >> $out/nix-support/propagated-user-env-packages
    echo ${kdePackages.kiconthemes} >> $out/nix-support/propagated-user-env-packages
    echo ${kdePackages.kirigami} >> $out/nix-support/propagated-user-env-packages
    echo ${kdePackages.plasma5support} >> $out/nix-support/propagated-user-env-packages
    echo ${kdePackages.ksvg} >> $out/nix-support/propagated-user-env-packages
    echo ${kdePackages.qt5compat} >> $out/nix-support/propagated-user-env-packages
    echo ${kdePackages.qtdeclarative} >> $out/nix-support/propagated-user-env-packages
    echo ${kdePackages.qtsvg} >> $out/nix-support/propagated-user-env-packages
  '';

  meta = with lib; {
    description = "Astronaut theme for SDDM";
    homepage = "https://github.com/Keyitdev/sddm-astronaut-theme";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
    maintainers = with maintainers; [ ];
  };
}
