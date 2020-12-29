# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # TODO: Don't repeat the common domain everywhere
  domain = "example.com";
in
{
  boot.loader.grub.enable = false;
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 4;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  console = {
    keyMap = "uk";
  };

  networking.wireless = {
    enable = true;
  };

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.interfaces.wlan0.useDHCP = true;

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  # List services that you want to enable:

  services.udev.packages = [ pkgs.btuart ];
  services.telegraf = {
    enable = true;
    extraConfig = {
      outputs.socket_writer = [
        {
          address = "tcp://grafana.${domain}:8094";
          data_format = "influx";
          tls_ca = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        }
      ];
      inputs.cpu = [
        {
          percpu = false;
          totalcpu = true;
          collect_cpu_time = false;
          report_active = false;
        }
      ];
      inputs.disk = [
        {
          ignore_fs = [ "tmpfs" "devtmpfs" "devfs" "overlay" "aufs" "squashfs" ];
        }
      ];
      inputs.diskio = [{}];
      inputs.kernel = [{}];
      inputs.mem = [{}];
      inputs.swap = [{}];
      inputs.system = [{}];
      inputs.socket_listener = [
        {
          service_address = "tcp://127.0.0.1:8094";
          data_format = "influx";
        }
      ];
    };
  };

  systemd.services = {
    sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
    wpa_supplicant = {
      # wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
      before = pkgs.lib.mkForce [];
      after = pkgs.lib.mkForce [ "network-online.target" ];
    };

    hciuart = {
      description = "Configure Bluetooth Modems connected by UART";
      unitConfig = {
        ConditionFileNotEmpty = "/proc/device-tree/soc/gpio@7e200000/bt_pins/brcm,pins";
      };
      requires = [ "dev-serial1.device" ];
      after = [ "dev-serial1.device" ];
      wantedBy = [ "ruuvitag-listener.service" ];
      script = ''
        ${pkgs.btuart}/bin/btuart
      '';
    };

    ruuvitag-listener = {
      description = "ruuvitag listener";
      wantedBy = [ "multi-user.target" ];
      wants = [ "telegraf.service" ];
      after = [ "bluetooth.target" "wpa_supplicant.service" "telegraf.service" ];
      script = ''
        /run/wrappers/bin/ruuvitag-listener | ${pkgs.netcat}/bin/nc 127.0.0.1 8094
      '';
      serviceConfig = {
        Restart = "always";
        RestartSec = 30;
        StartLimitIntervalSec = 0;
        IgnoreSIGPIPE = false;
      };
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: with pkgs; {
      ruuvitag-listener = callPackage ../pkgs/ruuvitag-listener { };
      btuart = callPackage ../pkgs/btuart { };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    curl git vim emacs-nox
    ruuvitag-listener
    netcat
    btuart
  ];

  security = {
    wrappers.ruuvitag-listener = {
      source = "${pkgs.ruuvitag-listener}/bin/ruuvitag-listener";
      capabilities = "cap_net_raw,cap_net_admin+eip";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sjagoe = {
    isNormalUser = true;
    home = "/home/sjagoe";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa ..."
    ];
  };
}
