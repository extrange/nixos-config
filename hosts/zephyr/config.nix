{
  config,
  specialArgs,
  pkgs,
  lib,
  home-manager,
  nixvirt,
  ...
}:
{
  allowSsh = {
    enable = true;
    forRoot = true; # For virt-manager/qemu kvm access
  };
  ffmpegCustom = true;
  enablePrinting = true;
  fixLogiBoltSleep = true;
  graphical = true;
  ddcutil = true;
  remoteDesktop = true;
  uptime = {
    enable = true;
    url = "https://uptime.icybat.com/api/push/4RbFRv0UVQ?status=up&msg=OK&ping=";
  };
  zswap = true;

  # Secure Boot
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    configurationLimit = 8;
    enable = true;
    autoGenerateKeys.enable = true;
    autoEnrollKeys = {
      enable = true;
      autoReboot = true;
    };
    pkiBundle = "/var/lib/sbctl";
    measuredBoot = {
      enable = true;
      pcrs = [
        0
        4
        7
      ];
    };
  };

  # Fix name of ethernet adapter
  systemd.network.links."10-lan" = {
    matchConfig = {
      MACAddress = "24:4b:fe:45:61:6a"; # most reliable for a physical NIC
      # Path = "pci-0000:05:00.0";        # alternative: match by PCI slot
    };
    linkConfig = {
      Name = "lan";
    };
  };

  # Allow this host to redirect its USB devices to VMs
  virtualisation.spiceUSBRedirection.enable = true;

  # For ESP32 programming
  users.users."${config.userName}".extraGroups = [ "dialout" ];

  boot.kernelPatches = [
    {
      name = "add-acs-overrides";
      patch = pkgs.fetchurl {
        url = "https://aur.archlinux.org/cgit/aur.git/tree/1001-6.14.0-add-acs-overrides.patch?h=linux-vfio&id=bb9dbf9b13b404bc1b6b4349788deefe840447df";
        sha256 = "0qlzbrzxfc2kzizir9ifrsijkhmzkc93xazjp242gbganh4drrb9";
      };
    }
  ];

  # ZFS
  boot = {
    # With ZFS, we cannot use the latest kernel (linuxPackages_latest)
    kernelPackages = pkgs.linuxPackages;
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false; # Recommended disabled
  };
  boot.zfs.extraPools = [
    "vm-data"
    "vm-os"
  ];
  services.zfs.autoScrub.enable = true;

  home-manager.users.user = {

    home.packages = with pkgs; [
      clinfo # Check OpenCL
      darktable
      digikam
      nvtopPackages.amd
    ];

    dconf.settings = with home-manager.lib.hm.gvariant; {
      # Virt-manager connections
      "org/virt-manager/virt-manager/connections" = {
        uris = [ "qemu:///system" ];
      };
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
      };

      "org/gnome/mutter" = {
        # Fractional scaling
        experimental-features = [ "scale-monitor-framebuffer" ];
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
