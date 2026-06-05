{ lib, config, ... }:
with lib;
{

  options.enablePrinting = mkEnableOption "Whether to enable printing and setup the LAN printer too";

  config = mkIf config.enablePrinting {
    hardware.printers =
      let
        brother = "Brother_MFC-J470DW";
      in
      {
        ensurePrinters = [
          {
            name = brother;
            location = "Home";
            deviceUri = "ipp://192.168.1.101/ipp";
            model = "everywhere";
          }
        ];
        ensureDefaultPrinter = brother;

      };
  };
}
