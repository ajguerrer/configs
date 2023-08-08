{ config, ... }:
{
  # enable bash autocompletion for system packages
  environment.pathsToLink = [ "/share/bash-completion" ];
}