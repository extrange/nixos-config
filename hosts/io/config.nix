{
  lib,
  ...
}:
{
  allowSsh.enable = true;
  zswap = true;

  # The VPS doesn't support UEFI
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub.configurationLimit = 3;

  # Allow use as exit node
  services.tailscale.useRoutingFeatures = "server";

  # io monitors itself over loopback.
  monitoring.client = {
    enable = true;
    serverAddress = "127.0.0.1";
  };

  home-manager.users.user = { };
}
