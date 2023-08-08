{ config, system, inputs, ... }:
{
  programs.anyrun = {
    enable = true;

    config = {
      plugins = with inputs.anyrun.packages.${system}; [
        applications
	      rink
	      shell
	      kidex
	      randr
      ];

      width.absolute = 600;
      height.absolute = 0;
      y.fraction = 0.3;
      hidePluginInfo = true;
      closeOnClick = true;
    };

    extraCss = ''
      #window,
      #match,
      #entry,
      #plugin,
      #main {
        background: transparent;
      }

      #match:selected {
        background: @theme_selected_bg_color;
      }

      #match {
        padding: 3px;
        border-radius: 16px;
      }

      #entry, #plugin:hover {
        border-radius: 16px;
      }

      box#main {
        background: @theme_bg_color;
        border: 1px solid @theme_base_color;
        border-radius: 24px;
        padding: 8px;
      }
    '';
  };
}
