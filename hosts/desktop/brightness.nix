{
  pkgs,
  ...
}:
{
  # Adjust brightness automatically
  systemd.user =

    let
      evening = "18:00";
      morning = "07:00";
      scriptName = "display-brightness";
      toggleScript = pkgs.writeShellApplication {
        name = scriptName;
        runtimeInputs = [
          pkgs.ddcutil
          pkgs.gawk
        ];
        text = ''
          time_now=10#$(date +%H%M)
          start=10#$(echo '${evening}' | tr -d ':')  # "18:00" → "1800"
          end=10#$(echo '${morning}' | tr -d ':')      # "07:00" → "0700"

          # read display numbers into array
          readarray -t displays < <(
            ddcutil detect --brief \
              | awk '/^Display/ { print $2 }'
          )

          for disp in "''${displays[@]}"; do
            if [[ "$time_now" -ge "$end" ]] && [[ "$time_now" -lt "$start" ]]; then
              echo "Brightening display $disp"
              ddcutil setvcp --display "$disp" 10 8
              echo "Display $disp brightened"
            else
              echo "Dimming display $disp"
              ddcutil setvcp --display "$disp" 10 0
              echo "Display $disp dimmed"
            fi
          done
        '';
      };
      # Convert "HH:MM" → "*-*-* HH:MM:00"
      toSystemdTime =
        time:
        let
          hh = builtins.substring 0 2 time;
          mm = builtins.substring 3 2 time;
        in
        "*-*-* ${hh}:${mm}:00";
    in
    {
      services."${scriptName}" = {
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        unitConfig = {
          Description = "Adjust display brightness automatically";
        };
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${toggleScript}/bin/${scriptName}";
        };
      };
      timers."${scriptName}" = {
        unitConfig.Description = "Run display-brightness service at start/end of DND hours";
        timerConfig = {
          Persistent = true;
          OnCalendar = [
            (toSystemdTime evening)
            (toSystemdTime morning)
          ];
        };
        wantedBy = [ "timers.target" ];
      };
    };
}
