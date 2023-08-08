{pkgs, ...}: let
  audioOffScript = pkgs.writeShellScript "if-audio-off" ''
    ${pkgs.pipewire}/bin/pw-cli i all | ${pkgs.ripgrep}/bin/rg running
    # only run cmd if audio isn't running
    if [ $? == 1 ]; then
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
        command = "${audioOffScript.outPath} ${pkgs.systemd}/bin/systemctl suspend";
      }
      {
        timeout = 110;
        command = "${audioOffScript.outPath} ${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        resumeCommand = "${audioOffScript.outPath} ${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
    ];
  };
}