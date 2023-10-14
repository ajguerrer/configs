{config, lib, pkgs, user, ... }:
{
  imports = [
    ../../modules/anyrun/home.nix
    ../../modules/bash/home.nix
    ../../modules/dunst/home.nix
    ../../modules/eww/home.nix
    ../../modules/gpg/home.nix
    ../../modules/gtk/home.nix
    ../../modules/hyprland/home.nix
    ../../modules/starship/home.nix
    ../../modules/swaybg/home.nix
    ../../modules/swayidle/home.nix
    ../../modules/xdg/home.nix
  ];

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = with pkgs; [ 
      gh
      ripgrep 
      alacritty
    ];
    sessionVariables = {
      # BROWSER = "google-chrome-stable";
      VISUAL="code --wait --new-window";
      EDITOR="nvim";
    };
  };

  programs = {
    vscode.enable = true;
    git = {
      enable = true;
      userEmail = "ajguerrer@gmail.com";
      userName = "Andrew Guerrero";
      extraConfig = {
        http.postBuffer = 524288000;
        pull.rebase = true;
        rebase.autoStash = true;
        diff.tool = "vscode";
        difftool."vscode".cmd = "code --wait --diff $LOCAL $REMOTE";
        credential = {
          "https://github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
          "https://gist.github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
        };
      };
    };
  };

  programs.home-manager.enable = true;

  home.stateVersion = "23.05";
}
