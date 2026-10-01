{
  config,
  pkgs,
  home-manager,
  ...
}:
let
  user = config.userName;
in
{
  imports = [ ./brightness.nix ];
  graphical = true;
  ddcutil = true;
  allowSsh.enable = true;
  ffmpegCustom = true;
  enablePrinting = true;
  remoteDesktop = true;

  # Force primary display to always be detected as on (for streaming)
  hardware.display.edid.packages = [
    (pkgs.runCommandLocal "edid-p2715q" { } ''
      mkdir -p $out/lib/firmware/edid
      cp ${./edid-p2715q.bin} $out/lib/firmware/edid/p2715q.bin
    '')
  ];

  # Pin the primary monitor's EDID to the DP connector
  hardware.display.outputs."DP-1".edid = "p2715q.bin";
  hardware.display.outputs."DP-1".mode = "e"; # Force always on

  services = {
    sunshine = {
      enable = true;
      autoStart = true; # optional: starts Sunshine automatically on login
      capSysAdmin = true;
      openFirewall = true;
    };
  };

  users.users."${user}".extraGroups = [
    "uinput" # Moonlight: fix cursor not moving
    "dialout" # For ESP32 programming
    "scanner"
  ];

  environment.variables.MUTTER_DEBUG_DISABLE_HW_CURSORS = 1; # fix curson not showing

  # Intel GPU
  hardware.graphics.extraPackages = with pkgs; [
    vpl-gpu-rt # Intel QSV
    intel-media-driver # VAAPI (iHD) — hw video decode; needed by moonlight-qt/Firefox
    intel-compute-runtime
  ];

  # Force xe drivers (over i915)
  # boot.kernelParams = [
  #   "i915.force_probe=!*"
  #   "xe.force_probe=*"
  # ];

  # Allow this host to redirect its USB devices to VMs
  virtualisation.spiceUSBRedirection.enable = true;

  # Scanner
  hardware.sane = {
    enable = true;
    brscan4 = {
      enable = true;
      netDevices = {
        MFCJ470DW = {
          ip = "192.168.1.101";
          model = "MFC-J470DW";
        };
      };
    };
  };

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
          idle-delay = mkUint32 3600; # 60mins
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
