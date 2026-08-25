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
  allowSsh = {
    enable = true;
    forRoot = true; # Chanel's btrbk-archive
  };
  ffmpegCustom = true;
  enablePrinting = true;
  fixLogiBoltSleep = true;
  remoteDesktop = true;

  # Intel GPU
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
  ];

  users.users."${config.userName}".extraGroups = [
    "dialout" # For ESP32 programming
  ];

  home-manager.users.user = {
    home.packages = with pkgs; [
      darktable
      digikam
      nvtopPackages.amd
    ];

    dconf.settings = with home-manager.lib.hm.gvariant; {
      "org/gnome/mutter" = {
        # Fractional scaling
        experimental-features = [ "scale-monitor-framebuffer" ];
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
          "_temperature_amdgpu_edge_"
        ];
      };
    };
  };
}
