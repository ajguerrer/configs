{ config, pkgs, user, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/amd
    ../../modules/bash
    ../../modules/docker
    ../../modules/fonts
    ../../modules/gc
    ../../modules/hyprland
    ../../modules/rust
    ../../modules/xdg
  ];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "auto";
      };  
      efi.canTouchEfiVariables = true;
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  nixpkgs = {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.wireshark = {};
  programs.wireshark.enable = true;
  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = [ "networkmanager" "wheel" "docker" "wireshark" "libvirtd" "audio" "video" ];
    packages = with pkgs; [
      bottom
      gnome.gnome-font-viewer
      gnome.nautilus
      google-chrome
      neovim
      oha
      spotify
      tshark
      wireshark
    ];
  };

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "echidna"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  services = {
    xserver = {
      layout = "us";
      xkbVariant = "";
    };

    # Enable automatic login for the user.
    getty.autologinUser = "${user}";
    
    gvfs.enable = true;

    dbus.enable = true;
    
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    logind.extraConfig = ''
      # suspend when power button is short-pressed
      HandlePowerKey=suspend
    '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

