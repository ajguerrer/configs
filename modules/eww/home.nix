{config, pkgs, lib, user, ...}: let
dependencies = with pkgs; [
  eww-wayland
  bash
  libnotify
  inotify-tools
];
in
{
  home.packages = with pkgs; [
    libnotify
    inotify-tools
  ];

  programs.eww = {
    enable = true;
    package = pkgs.eww-wayland;
    configDir = ./config;
  };

  systemd.user.services.eww = {
    Unit = {
      Description = "Eww Daemon";
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath dependencies} XDG_DATA_DIRS=/etc/profiles/per-user/andrew/share";
      ExecStart = "${pkgs.eww-wayland}/bin/eww daemon --no-daemonize";
      Restart = "on-failure";
      User = "${user}";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}