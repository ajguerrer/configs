{ config, pkgs, inputs, system, lib, ... }:
{
  programs = {
    bash.initExtra = ''
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi
    '';
  };

  home.packages = with pkgs; [
    gnome.gnome-keyring
    gnome.seahorse
    grim
    slurp
    hyprpicker
    inputs.hyprland-contrib.packages.${system}.grimblast    
    wl-clipboard
    wlr-randr
  ];

  services.gnome-keyring = {
    enable = true;
    components = ["pkcs11" "secrets" "ssh"];
  };

  systemd.user.targets.hyperland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];

  # start swayidle as part of hyprland, not sway
  systemd.user.services.swayidle.Install.WantedBy = lib.mkForce ["hyprland-session.target"];

  # make stuff work on wayland
  home.sessionVariables = {
    GDK_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";

    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";

    NIXOS_OZONE_WL = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    CLUTTER_BACKEND = "wayland";
    WLR_RENDERER = "vulkan";
    
    POLKIT_AUTH_AGENT = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    extraConfig = ''
    $mod = SUPER

    exec-once = eww open bar

    # Some default env vars.
    env = XCURSOR_SIZE,32

    # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
    input {
      kb_layout = us
      kb_variant =
      kb_model =
      kb_options =
      kb_rules =

      follow_mouse = 1

      touchpad {
        natural_scroll = false
      }

      sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
    }

    general {
      gaps_in = 0
      gaps_out = 0
      border_size = 2
      col.active_border = rgb(BF9BAE)
      col.inactive_border = rgb(48484D)

      layout = dwindle # master|dwindle 
    }

    decoration {
      rounding = 4

      blur {
        enabled = true
        size = 3
        passes = 1
      }

      drop_shadow = true
      shadow_range = 4
      shadow_render_power = 3
      col.shadow = rgba(00000099)
    }

    animations {
      # See https://wiki.hyprland.org/Configuring/Animations/ for more

      enabled = true
      animation = border, 1, 2, default
      animation = fade, 1, 4, default
      animation = windows, 1, 3, default, popin 80%
      animation = workspaces, 1, 2, default, slide
    }

    dwindle {
      # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
      pseudotile = true # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
      preserve_split = true # you probably want this
    }

    master {
      # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
      new_is_master = true
    }
    
    gestures {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more
      workspace_swipe = false
    }

    misc {
      disable_autoreload = true
      disable_hyprland_logo = true
    }

    # only allow shadows for floating windows
    windowrulev2 = noshadow, floating:0

    # idle inhibit while watching videos
    windowrulev2 = idleinhibit focus, class:^(chrome)$, title:^(.*YouTube.*)$
    windowrulev2 = idleinhibit fullscreen, class:^(chrome)$

    windowrulev2 = dimaround, class:^(gcr-prompter)$

    # fix xwayland apps
    windowrulev2 = rounding 0, xwayland:1, floating:1

    layerrule = blur, ^(gtk-layer-shell|anyrun)$
    layerrule = ignorezero, ^(gtk-layer-shell|anyrun)$

    # mouse movements
    bindm = $mod, mouse:272, movewindow
    bindm = $mod, mouse:273, resizewindow
    bindm = $mod ALT, mouse:272, resizewindow

    # compositor commands
    bind = $mod SHIFT, E, exec, pkill Hyprland
    bind = $mod, Q, killactive,
    bind = $mod, F, fullscreen,
    bind = $mod, G, togglegroup,
    bind = $mod SHIFT, N, changegroupactive, f
    bind = $mod SHIFT, P, changegroupactive, b
    bind = $mod, R, togglesplit,
    bind = $mod, T, togglefloating,
    bind = $mod, P, pseudo,
    bind = $mod ALT, ,resizeactive,

    # utility
    # launcher
    bindr = $mod, SUPER_L, exec, anyrun

    # move focus
    bind = $mod, left, movefocus, l
    bind = $mod, right, movefocus, r
    bind = $mod, up, movefocus, u
    bind = $mod, down, movefocus, d

    # window resize
    bind = $mod, S, submap, resize

    submap = resize
    binde = , right, resizeactive, 10 0
    binde = , left, resizeactive, -10 0
    binde = , up, resizeactive, 0 -10
    binde = , down, resizeactive, 0 10
    bind = , escape, submap, reset
    submap = reset

    # screenshot
    # stop animations while screenshotting; makes black border go away
    $screenshotarea = hyprctl keyword animation "fadeOut,0,0,default"; grimblast --notify copysave area; hyprctl keyword animation "fadeOut,1,4,default"
    bind = , Print, exec, $screenshotarea
    bind = $mod SHIFT, R, exec, $screenshotarea

    bind = CTRL, Print, exec, grimblast --notify --cursor copysave output
    bind = $mod SHIFT CTRL, R, exec, grimblast --notify --cursor copysave output

    bind = ALT, Print, exec, grimblast --notify --cursor copysave screen
    bind = $mod SHIFT ALT, R, exec, grimblast --notify --cursor copysave screen

    # workspaces
    # binds mod + [shift +] {1..10} to [move to] ws {1..10}
    ${builtins.concatStringsSep "\n" (builtins.genList (
        x: let
          ws = let
            c = (x + 1) / 10;
          in
            builtins.toString (x + 1 - (c * 10));
        in ''
          bind = $mod, ${ws}, workspace, ${toString (x + 1)}
          bind = $mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
        ''
      )
      10)}

    # cycle workspaces
    bind = $mod, bracketleft, workspace, m-1
    bind = $mod, bracketright, workspace, m+1
    # cycle monitors
    bind = $mod SHIFT, braceleft, focusmonitor, l
    bind = $mod SHIFT, braceright, focusmonitor, r
    '';
  };
}
