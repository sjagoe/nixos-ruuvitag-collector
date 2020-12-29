# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  hostname = "listener-1";
  telegrafReplacements = (import ../ruuvitag-beacons.nix { hostname = hostname; });
in
{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ../common.nix
      ../sshd-server.nix
      ../listener-common.nix
      # This file doesn't exist in the repository. It should be
      # created on the target host.  See ../wifi-secrets.nix.example
      ../wifi-secrets.nix
    ];

  system.stateVersion = "20.09";

  networking.hostName = "${hostname}";
  services.telegraf = {
    extraConfig = {
      processors.regex = [
        {
          namepass = ["ruuvi_measurement"];
          tags = telegrafReplacements;
        }
      ];
    };
  };
}
