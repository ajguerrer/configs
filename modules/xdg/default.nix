{pkgs, ...}:
{
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      lxqt.xdg-desktop-portal-lxqt
    ];
  };
}