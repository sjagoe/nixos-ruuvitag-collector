{ config, pkgs, ... }:

{
  networking.wireless.networks = {
    NetworkName = {
      # Generate the value with "wpa_passphrase NetworkName"
      pskRaw = "wpa_passphrase NetworkName";
    };
  };
}
