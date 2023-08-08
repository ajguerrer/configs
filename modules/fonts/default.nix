{config, pkgs, ...}:

{
  fonts = {
    fonts = with pkgs; [
      # ui
      roboto
      inter
      inter-ui

      # monospace
      iosevka
      ( nerdfonts.override { fonts = [ "Iosevka"]; } )

      # unicode
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      noto-fonts-extra
    ];

    fontconfig.enable = true;
  };
}