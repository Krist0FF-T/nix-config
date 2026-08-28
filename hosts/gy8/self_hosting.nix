{ pkgs, ... }:
{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud34;
    hostName = "localhost";
    config.adminpassFile = "/etc/nextcloud-admin-pass";
    config.dbtype = "sqlite";
    settings.trusted_domains = [
      "*.ts.net"  # for hosting on my tailnet
      "192.168.*" # for hosting locally
    ];
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  # See https://nixos.wiki/wiki/Samba
  services.samba = {
    enable = true;
    openFirewall = true;

    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
        # ..
        "hosts allow" = "100. 192.168.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "share" = {
        "path" = "/srv/share/";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
