{ config, pkgs, ... }:

let
  # TODO: Don't duplicate the domain definition everywhere
  domain = "example.com";
in
{
  services = {
    influxdb = {
      enable = true;
      dataDir = "/var/db/influxdb";
    };
    telegraf = {
      enable = true;
      extraConfig = {
        outputs.influxdb = [
          {
            urls = ["http://localhost:8086"];
            database = "telegraf";
            skip_database_creation = true;
            namedrop = ["ruuvi_measurement"];
          }
          {
            urls = ["http://localhost:8086"];
            database = "environment-sensors";
            skip_database_creation = true;
            namepass = ["ruuvi_measurement"];
            tagdrop = {
              "name" = ["*:*"];
            };
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
            service_address = "tcp://:8094";
            data_format = "influx";
            tls_cert = "${config.security.acme.certs."grafana.${domain}".directory}/fullchain.pem";
            tls_key = "${config.security.acme.certs."grafana.${domain}".directory}/key.pem";
          }
        ];
      };
    };

    grafana = {
      enable = true;
      dataDir = "/var/db/grafana";
      domain = "grafana.${domain}";
      rootUrl = "https://%(domain)s";
      protocol = "http";
      smtp.enable = true;
      smtp.fromAddress = "grafana@${domain}";
    };
  };
}
