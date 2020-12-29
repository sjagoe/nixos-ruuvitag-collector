{ hostname, ... }:

let
  toTelegraf = item: { key =  "name"; pattern = "^${item.mac}$"; replacement = item.name; };
in
{
  listener-1 = rec {
    location = "downstairs";
    description = ''
        Raspberry Pi 4, 2GB. Located in a cupboard at the back of the lounge
      '';
    beacons = [
      { mac = "AB:CD:EF:01:23:40"; name = "Outside";    }
      { mac = "AB:CD:EF:01:23:41"; name = "Storage";    }
      { mac = "AB:CD:EF:01:23:42"; name = "Sauna";      }
      { mac = "AB:CD:EF:01:23:43"; name = "Lounge";     }
    ];
    telegrafReplacements = map toTelegraf beacons;
  };
  listener-2 = rec {
    location = "upstairs";
    description = ''
        Raspberry Pi 4, 2GB. Located on a bookshelf upstairs
      '';
    beacons = [
      { mac = "AB:CD:EF:01:23:44"; name = "Loft";     }
      { mac = "AB:CD:EF:01:23:45"; name = "Upstairs"; }
    ];
    telegrafReplacements = map toTelegraf beacons;
  };
}."${hostname}".telegrafReplacements
