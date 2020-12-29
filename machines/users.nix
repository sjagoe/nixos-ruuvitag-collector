{ config, pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.mutableUsers = false;
  users = {
    extraUsers.sjagoe = {
      name = "sjagoe";
      group = "sjagoe";
      uid = 1000;
      extraGroups = [ "wheel" ];
      useDefaultShell = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa ..."
        "ssh-rsa ..."
      ];
    };
    extraGroups = {
      sjagoe = {
        name = "sjagoe";
        gid = 1000;
      };
    };
  };
}
