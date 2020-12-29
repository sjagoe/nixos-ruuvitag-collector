{ config, pkgs, ... }:

{
  networking = {
    firewall = {
      allowPing = true;
    };
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_GB.UTF-8";
  };
  console = {
    font = "Lat2-Terminus16";
  };

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  programs = {
    bash = {
      enableCompletion = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      emacs26-nox
      bash
      htop
      iotop
      tmux
    ];
  };
}
