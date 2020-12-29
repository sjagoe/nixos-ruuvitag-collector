# builtins.replaceStrings [ "/usr/bin/btattach" ] [ "${pkgs.blues}/bin/btattach" ]
{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "btuart";
  version = "0.0.1";
  src = builtins.path {
    path = ./.;
    name = "btuart";
  };

  buildInputs = [ pkgs.gnused pkgs.bash ];
  propagatedBuildInputs = [ pkgs.bluez ];

  phases = [ "installPhase" "fixupPhase" ];

  installPhase = ''
    mkdir -p $out/bin $out/lib/udev/rules.d
    cp $src/btuart.sh $out/bin/btuart
    cp $src/90-pi-bluetooth-custom.rules $out/lib/udev/rules.d/90-pi-bluetooth-custom.rules
    cp $src/99-serial-custom.rules $out/lib/udev/rules.d/99-serial-custom.rules
    chmod u+x $out/bin/btuart
  '';

  postFixup = ''
    sed -i "s#/usr/bin/btattach#${pkgs.bluez}/bin/btattach#" $out/bin/btuart
    sed -i "s#/bin/sh#${pkgs.bash}/bin/sh#" $out/lib/udev/rules.d/99-serial-custom.rules
  '';
}
