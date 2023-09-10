{pkgs, user, ...}: let
  inhibitScript = pkgs.writeShellScript "if-audio-off" ''
    ${pkgs.pipewire}/bin/pw-cli i all | ${pkgs.ripgrep}/bin/rg running
    # only run cmd if audio isn't running
    if [ $? == 1 ] && [ ! -f "/home/${user}/.cache/inhibit" ]; then
      "$@"
    fi
  '';
in {
  # screen idle
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 330;
        command = "${inhibitScript.outPath} ${pkgs.systemd}/bin/systemctl suspend";
      }
      {
        timeout = 110;
        command = "${inhibitScript.outPath} ${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        resumeCommand = "${inhibitScript.outPath} ${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
    ];
  };
}