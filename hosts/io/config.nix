{
  lib,
  ...
}:
{
  allowSsh.enable = true;
  zswap = true;

  # Caddy's HTTP listener; it only redirects to HTTPS.
  networking.firewall.allowedTCPPorts = [ 80 ];

  # Tailscale WireGuard; allows direct tailnet connections instead of DERP.
  networking.firewall.allowedUDPPorts = [ 41641 ];

  # Security: This VPS has no LAN peers to discover, and the LLMNR responder would
  # otherwise be reachable by every device on the tailnet.
  services.resolved.settings.Resolve = {
    LLMNR = false;
    MulticastDNS = false;
  };

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
