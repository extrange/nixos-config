{
  config,
  pkgs,
  home-manager,
  ...
}:
{
  imports = [ ./brightness.nix ];
  graphical = true;
  ddcutil = true;
  allowSsh.enable = true;
  ffmpegCustom = true;
  enablePrinting = true;
  fixLogiBoltSleep = true;
  remoteDesktop = true;

  # Intel GPU
  hardware.graphics.extraPackages = with pkgs; [
    vpl-gpu-rt # Intel QSV
    intel-media-driver # VAAPI (iHD) — hw video decode; needed by moonlight-qt/Firefox
    intel-compute-runtime
  ];

  # Force xe drivers (over i915)
  boot.kernelParams = [
    "i915.force_probe=!*"
    "xe.force_probe=*"
  ];

  # Allow this host to redirect its USB devices to VMs
  virtualisation.spiceUSBRedirection.enable = true;

  users.users."${config.userName}".extraGroups = [
    "dialout" # For ESP32 programming
  ];

  home-manager.users.user = {
    home.packages = with pkgs; [
      darktable
      digikam
      nvtopPackages.intel
    ];

    dconf.settings =
      with home-manager.lib.hm.gvariant;
      let
        qemuUris = [ "qemu:///system" ];
      in
      {
        # Virt-manager connections
        "org/virt-manager/virt-manager/connections" = {
          uris = qemuUris;
        };
        "org/virt-manager/virt-manager/connections" = {
          autoconnect = qemuUris;
        };
        "org/gnome/desktop/session" = {
          idle-delay = mkUint32 900; # 15mins
        };

        "org/gnome/shell/extensions/vitals" = {
          hot-sensors = [
            "_processor_usage_"
            "_memory_usage_"
            "_temperature_processor_0_"
            "__network-rx_max__"
          ];
        };
      };
  };

}
