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
    grim
    slurp
    hyprpicker
    inputs.hyprland-contrib.packages.${system}.grimblast    
    wl-clipboard
    wlr-randr
  ];

  services.gnome-keyring.enable = true;

  systemd.user.targets.hyperland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];

  # start swayidle as part of hyprland, not sway
  systemd.user.services.swayidle.Install.WantedBy = lib.mkForce ["hyprland-session.target"];

  # make stuff work on wayland
  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    nvidiaPatches = false;
    extraConfig = ''
    $mod = SUPER

    exec-once = eww open bar

    # use this instead of hidpi patches
    xwayland {
      force_zero_scaling = true
    }

    input {
      kb_layout = us

      # focus change on cursor move
      follow_mouse = 1
      accel_profile = flat
      touchpad {
        scroll_factor = 0.3
      }
    }

    general {
      gaps_in = 0
      gaps_out = 0
      border_size = 2
      col.active_border = rgb(BE9DAD)
      col.inactive_border = rgb(43454C)

      layout = dwindle # master|dwindle 
    }

    dwindle {
      # keep floating dimentions while tiling
      pseudotile = true
      preserve_split = true
    }

    master {
      new_is_master = true
      special_scale_factor = 0.8
      new_is_master = true
      no_gaps_when_only = false
    }

    decoration {
      rounding = 4
      blur = true
      blur_size = 3
      blur_passes = 3
      blur_new_optimizations = true

      drop_shadow = true
      shadow_ignore_window = true
      shadow_offset = 0 5
      shadow_range = 50
      shadow_render_power = 3
      col.shadow = rgba(00000099)
    }

    animations {
      enabled = true
      animation = border, 1, 2, default
      animation = fade, 1, 4, default
      animation = windows, 1, 3, default, popin 80%
      animation = workspaces, 1, 2, default, slide
    }

    gestures {
      workspace_swipe = true
      workspace_swipe_fingers = 4
      workspace_swipe_distance = 250
      workspace_swipe_invert = true
      workspace_swipe_min_speed_to_force = 15
      workspace_swipe_cancel_ratio = 0.5
      workspace_swipe_create_new = false
    }

    misc {
      disable_autoreload = true
      disable_hyprland_logo = true
      always_follow_on_dnd = true
      layers_hog_keyboard_focus = true
      animate_manual_resizes = false
      enable_swallow = true
      swallow_regex =
      focus_on_activate = true
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
