{pkgs, user, ...}: let
  suspendScript = pkgs.writeShellScript "if-suspend" ''
    if [ ! -f "/home/${user}/.cache/inhibit" ] &&
    # only run cmd if audio isn't running
    ! ${pkgs.pipewire}/bin/pw-cli i all | ${pkgs.ripgrep}/bin/rg running &&
    # only run cmd if nobody is connected
    ! ss -t -a | rg ESTAB.*:ssh; then
      "$@"
    fi
  '';
  monitorScript = pkgs.writeShellScript "if-monitor" ''
    if [ ! -f "/home/${user}/.cache/inhibit" ] && 
    # only run cmd if audio isn't running
    ! ${pkgs.pipewire}/bin/pw-cli i all | ${pkgs.ripgrep}/bin/rg running; then
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
        command = "${suspendScript.outPath} ${pkgs.systemd}/bin/systemctl suspend";
      }
      {
        timeout = 110;
        command = "${monitorScript.outPath} ${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
    ];
  };
}