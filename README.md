# Helpful commands

## Update

`nix flake update && sudo nixos-rebuild switch --flake .#echidna`

or if changing bootloader 

`nix flake update && sudo nixos-rebuild switch --install-bootloader --flake .#echidna`

## Clean

`sudo nix-collect-garbage -d && sudo nix store optimise`
