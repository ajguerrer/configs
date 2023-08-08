{ pkgs, default, ...}: {
  # notification daemon
  services.dunst = {
    enable = true;
    iconTheme = {
      name = "Tela-pink-dark";
      package = pkgs.tela-icon-theme;
    };
    settings = {
      global = {
        alignment = "center";
        corner_radius = 16;
        follow = "mouse";
        font = "Inter 10";
        format = "<b>%s</b>\\n%b";
        frame_width = 3;
        offset = "5x5";
        horizontal_padding = 8;
        icon_position = "left";
        indicate_hidden = "yes";
        markup = "yes";
        max_icon_size = 64;
        mouse_left_click = "do_action";
        mouse_middle_click = "close_all";
        mouse_right_click = "close_current";
        padding = 8;
        plain_text = "no";
        separator_color = "auto";
        separator_height = 1;
        show_indicators = false;
        shrink = "no";
        word_wrap = "yes";
      };

      fullscreen_delay_everything = {fullscreen = "delay";};

      urgency_critical = {
        background = "#43454C";
        foreground = "#A9AAB2";
        frame_color = "#BEAD9D";
      };
      urgency_low = {
        background = "#43454C";
        foreground = "#A9AAB2";
        frame_color = "#9DB3BE";
      };
      urgency_normal = {
        background = "#43454C";
        foreground = "#A9AAB2";
        frame_color = "#BE9DAD";
      };
    };
  };
}