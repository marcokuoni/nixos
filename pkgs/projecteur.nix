# Projecteur (current develop line, Qt6 / Wayland) for NixOS.
# Needs nixpkgs with Plasma libs >= 6.7 and Qt >= 6.10 (nixos-unstable; 26.05 is too old).
{
  lib,
  stdenv,
  src,
  version ? "unstable",
  cmake,
  pkg-config,
  gettext,
  kdePackages,
}:

stdenv.mkDerivation {
  pname = "projecteur";
  inherit version src;

  nativeBuildInputs = [
    cmake
    pkg-config
    gettext
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
    kdePackages.qtshadertools
    kdePackages.qttools
  ];

  buildInputs = with kdePackages; [
    qtbase
    qtdeclarative
    qtwayland
    qtshadertools
    kconfig
    kconfigwidgets
    kcoreaddons
    kdbusaddons
    kglobalaccel
    ki18n
    knotifications
    kpackage
    kirigami
    kwidgetsaddons
    kwindowsystem
    kxmlgui
    kpipewire
    libplasma
    layer-shell-qt
  ];

  # Upstream builds with -Werror; a newer compiler warning shouldn't break the build.
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "-Wall -Wextra -Werror" "-Wall -Wextra"
  '';

  cmakeFlags = [
    # Put the udev rules in the package so services.udev.packages can pick them up.
    "-DCMAKE_INSTALL_UDEVRULESDIR=${placeholder "out"}/lib/udev/rules.d"
    "-DPACKAGE_TARGETS=OFF"
  ];

  meta = {
    description = "Virtual laser pointer and magnifier for Logitech Spotlight and similar presenters";
    homepage = "https://github.com/gbin/Projecteur";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "projecteur";
  };
}
