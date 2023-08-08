{ config, pkgs, user, ... }:
{
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "erasedups" "ignorespace" ];
    }; 
  };
}
