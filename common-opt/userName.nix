{
  config,
  lib,
  ...
}:
with lib;
{
  options.userName = mkOption {
    type = types.str;
    description = "Name of the user to create";
    default = "user";
  };
}
