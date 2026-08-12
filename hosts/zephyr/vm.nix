{ nixvirt, lib, ... }:
{
  # VFIO Passthrough
  boot.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
  ];
  boot.kernelParams = [
    "pcie_acs_override=downstream,multifunction"
    "intel_iommu=on"
    "vfio-pci.ids=10de:2705,10de:22bb" # Nvidia GPU
  ];

  virtualisation = {
    libvirtd.qemu.swtpm.enable = true;

    # NixVirt
    libvirt.enable = true;
    libvirt.connections."qemu:///system" = {
      networks = [
        {
          definition = nixvirt.lib.network.writeXML (
            nixvirt.lib.network.templates.bridge {
              uuid = "27ec7197-429a-418e-9b91-d3bd43622869";
              subnet_byte = 122; # 192.168.122.0/24
            }
          );
          active = true;
        }
      ];
      domains = [
        {
          definition =
            let
              xml = nixvirt.lib.xml;
              pci = bus: slot: function: {
                type = "pci";
                domain = 0;
                inherit bus;
                inherit slot;
                inherit function;
              };
            in
            nixvirt.lib.domain.writeXML {
              type = "kvm";
              name = "win11";
              uuid = "ebe626a4-8541-46f4-9eb5-77d9d1cdc9f1";

              metadata = with xml; [
                (elem "libosinfo:libosinfo"
                  [ (attr "xmlns:libosinfo" "http://libosinfo.org/xmlns/libvirt/domain/1.0") ]
                  [ (elem "libosinfo:os" [ (attr "id" "http://microsoft.com/win/11") ] [ ]) ]
                )
              ];

              memory = {
                count = 20;
                unit = "GiB";
              };
              currentMemory = {
                count = 20;
                unit = "GiB";
              };
              vcpu = {
                placement = "static";
                count = 8;
              };

              cputune = {
                vcpupin =
                  lib.imap0
                    (v: c: {
                      vcpu = v;
                      cpuset = toString c;
                    })
                    [
                      2
                      3
                      4
                      5
                      8
                      9
                      10
                      11
                    ];
                emulatorpin = {
                  cpuset = "1,7";
                };
              };

              os = {
                firmware = "efi";
                type = "hvm";
                arch = "x86_64";
                machine = "pc-q35-10.1";
                loader = {
                  readonly = true;
                  secure = true;
                  type = "pflash";
                  path = "/run/libvirt/nix-ovmf/edk2-x86_64-secure-code.fd";
                };
                nvram = {
                  template = "/run/libvirt/nix-ovmf/edk2-i386-vars.fd";
                  templateFormat = "raw";
                  format = "raw";
                  path = "/var/lib/libvirt/qemu/nvram/win11_VARS.fd";
                };
                bootmenu = {
                  enable = false;
                };
              };

              features = {
                acpi = { };
                apic = { };
                hyperv = {
                  mode = "passthrough";
                };
                vmport = {
                  state = false;
                };
                smm = {
                  state = true;
                };
              };

              cpu = {
                mode = "host-passthrough";
                check = "none";
                migratable = false;
                topology = {
                  sockets = 1;
                  dies = 1;
                  cores = 4;
                  threads = 2;
                };
              };

              clock = {
                offset = "localtime";
                timer = [
                  {
                    name = "tsc";
                    present = true;
                    mode = "native";
                  }
                  {
                    name = "rtc";
                    tickpolicy = "catchup";
                  }
                  {
                    name = "pit";
                    tickpolicy = "delay";
                  }
                  {
                    name = "hpet";
                    present = false;
                  }
                  {
                    name = "hypervclock";
                    present = true;
                  }
                ];
              };

              on_poweroff = "destroy";
              on_reboot = "restart";
              on_crash = "destroy";

              pm = {
                suspend-to-mem = {
                  enabled = false;
                };
                suspend-to-disk = {
                  enabled = false;
                };
              };

              devices = {
                emulator = "/run/libvirt/nix-emulators/qemu-system-x86_64";

                disk = [
                  {
                    type = "block";
                    device = "disk";
                    driver = {
                      name = "qemu";
                      type = "raw";
                      cache = "none";
                      io = "native";
                      discard = "unmap";
                    };
                    source = {
                      dev = "/dev/zvol/vm-os/win11";
                    };
                    target = {
                      bus = "virtio";
                      dev = "vda";
                    };
                    boot = {
                      order = 2;
                    };
                    address = pci 7 0 0;
                  }
                  {
                    type = "block";
                    device = "disk";
                    driver = {
                      name = "qemu";
                      type = "raw";
                      cache = "none";
                      io = "native";
                      discard = "unmap";
                    };
                    source = {
                      dev = "/dev/zvol/vm-data/win11";
                    };
                    target = {
                      bus = "virtio";
                      dev = "vdb";
                    };
                    address = pci 8 0 0;
                  }
                ];

                controller = [
                  {
                    type = "usb";
                    index = 0;
                    model = "qemu-xhci";
                    ports = 15;
                    address = pci 2 0 0;
                  }
                  {
                    type = "pci";
                    index = 0;
                    model = "pcie-root";
                  }
                  {
                    type = "pci";
                    index = 1;
                    model = "pcie-root-port";
                    address = pci 0 2 0 // {
                      multifunction = true;
                    };
                  }
                  {
                    type = "pci";
                    index = 2;
                    model = "pcie-root-port";
                    address = pci 0 2 1;
                  }
                  {
                    type = "pci";
                    index = 3;
                    model = "pcie-root-port";
                    address = pci 0 2 2;
                  }
                  {
                    type = "pci";
                    index = 4;
                    model = "pcie-root-port";
                    address = pci 0 2 3;
                  }
                  {
                    type = "pci";
                    index = 5;
                    model = "pcie-root-port";
                    address = pci 0 2 4;
                  }
                  {
                    type = "pci";
                    index = 6;
                    model = "pcie-root-port";
                    address = pci 0 2 5;
                  }
                  {
                    type = "pci";
                    index = 7;
                    model = "pcie-root-port";
                    address = pci 0 2 6;
                  }
                  {
                    type = "pci";
                    index = 8;
                    model = "pcie-root-port";
                    address = pci 0 2 7;
                  }
                  {
                    type = "pci";
                    index = 9;
                    model = "pcie-root-port";
                    address = pci 0 3 0 // {
                      multifunction = true;
                    };
                  }
                  {
                    type = "pci";
                    index = 10;
                    model = "pcie-root-port";
                    address = pci 0 3 1;
                  }
                  {
                    type = "pci";
                    index = 11;
                    model = "pcie-root-port";
                    address = pci 0 3 2;
                  }
                  {
                    type = "pci";
                    index = 12;
                    model = "pcie-root-port";
                    address = pci 0 3 3;
                  }
                  {
                    type = "pci";
                    index = 13;
                    model = "pcie-root-port";
                    address = pci 0 3 4;
                  }
                  {
                    type = "pci";
                    index = 14;
                    model = "pcie-root-port";
                    address = pci 0 3 5;
                  }
                  {
                    type = "sata";
                    index = 0;
                    address = pci 0 31 2;
                  }
                  {
                    type = "virtio-serial";
                    index = 0;
                    address = pci 3 0 0;
                  }
                ];

                interface = [
                  {
                    type = "network";
                    mac = {
                      address = "52:54:00:b6:0f:23";
                    };
                    source = {
                      network = "default";
                    };
                    model = {
                      type = "virtio";
                    };
                    address = pci 1 0 0;
                  }
                  {
                    type = "direct";
                    mac = {
                      address = "52:54:00:b7:4a:51";
                    };
                    source = {
                      dev = "lan";
                      mode = "bridge";
                    };
                    model = {
                      type = "virtio";
                    };
                    address = pci 9 0 0;
                  }
                ];

                serial = {
                  type = "pty";
                  target = {
                    type = "isa-serial";
                    port = 0;
                    model = {
                      name = "isa-serial";
                    };
                  };
                };
                console = {
                  type = "pty";
                  target = {
                    type = "serial";
                    port = 0;
                  };
                };

                input = [
                  {
                    type = "tablet";
                    bus = "usb";
                    address = {
                      type = "usb";
                      bus = 0;
                      port = 1;
                    };
                  }
                  {
                    type = "mouse";
                    bus = "ps2";
                  }
                  {
                    type = "keyboard";
                    bus = "ps2";
                  }
                ];

                tpm = {
                  model = "tpm-crb";
                  backend = {
                    type = "emulator";
                    version = "2.0";
                  };
                };

                sound = {
                  model = "ich9";
                  address = pci 0 27 0;
                };
                audio = {
                  id = 1;
                  type = "none";
                };

                hostdev = [
                  {
                    mode = "subsystem";
                    type = "pci";
                    managed = true;
                    source = {
                      address = pci 1 0 0;
                    };
                    address = pci 4 0 0;
                  }
                  {
                    mode = "subsystem";
                    type = "pci";
                    managed = true;
                    source = {
                      address = pci 1 0 1;
                    };
                    address = pci 5 0 0;
                  }
                ];

                redirdev = {
                  bus = "usb";
                  type = "spicevmc";
                };

                watchdog = {
                  model = "itco";
                  action = "reset";
                };
                memballoon = {
                  model = "virtio";
                  address = pci 6 0 0;
                };
              };
            };
        }
      ];
    };
  };
}
