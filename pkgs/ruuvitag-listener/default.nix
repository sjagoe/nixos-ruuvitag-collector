{ stdenv, pkgs, fetchFromGitHub, rustPlatform, ... }:

rustPlatform.buildRustPackage rec {
  pname = "ruuvitag-listener";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "lautis";
    repo = pname;
    rev = "v${version}";
    sha256 = "1i0mibzgg17jryq62lkjc26wcp38b0g26rq6i5a2ndmhn7s0396f";
  };

  cargoSha256 = "1p7kw7lk4mdpv3n3xf95fpwdiqdjqq5cdl34liiwci99n2v57xxa";
  verifyCargoDeps = true;

  # Needs capabilities "cap_net_raw,cap_net_admin+eip"
}
