# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  domain = "example.com";
  hostname = "warehouse";
in
{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ../common.nix
      ../users.nix
      ../sshd-server.nix
      ./grafana.nix
    ];

  boot = {
    kernelPackages = pkgs.linuxPackages;
    # Use the gummiboot efi boot loader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
  };

  networking = {
    hostName = "${hostname}";
    hostId = "abcd1234";  # change this...
    enableIPv6 = false;
    firewall = {
      allowedTCPPorts = [
        # Web
        80 443
        # Telegraf
        8094
      ];
      allowedUDPPorts = [];
    };
    search = [ "${domain}" ];
    nameservers = [ "192.168.1.1" ];
  };

  console = {
    keyMap = "uk";
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
  ];

  security.acme = {
    acceptTerms = true;
    email = "simon@${domain}";
  };
  security.acme.certs = {
    "grafana.${domain}" = {
      email = "simon@${domain}";
      group = "grafana";
    };
  };

  # List services that you want to enable:
  services = {
    nginx = {
      enable = true;
      virtualHosts = {
        "grafana.${domain}" = {
          default = true;
          forceSSL = true;
          enableACME = true;
          acmeRoot = "/var/www/challenges";
          extraConfig = ''
            location = /robots.txt {
                allow all;
                add_header Content-Type text/plain;
                return 200 "User-agent: *\nDisallow: /\n";
            }
            location / {
                    # Only allow access from LAN
                    allow 192.168.1.0/24;
                    deny all;
                    proxy_pass http://localhost:3000;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header Host $host;
                    proxy_set_header X-Forwarded-Proto $scheme;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection $connection_upgrade;
                    proxy_buffering off;
            }
          '';
        };
      };
    };

    postfix = {
      enable = true;
      setSendmail = true;
      hostname = "${hostname}.${domain}";
      origin = "$mydomain";
      relayHost = "mail.myisp.example.com";
      rootAlias = "${hostname}+root@${domain}";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.extraUsers.guest = {
  #   isNormalUser = true;
  #   uid = 1000;
  # };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "19.09";

  users = {
    extraGroups = {
      # Allow access to letsencrypt certificates for grafana.${domain}
      grafana = {
        members = [ "telegraf" "nginx" ];
      };
    };
  };
}
