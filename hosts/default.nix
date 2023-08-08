{ system, self, nixpkgs, inputs, user, ... }:

let 
  pkgs = import nixpkgs {
    inherit system;
  };
  lib = nixpkgs.lib;
in
{
  echidna = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs user; };
    modules = [
      ./echidna
      inputs.hyprland.nixosModules.default
      inputs.home-manager.nixosModules.default {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit user system inputs; };
          users.${user} = {
            imports = [
              (import ./echidna/home.nix)
              inputs.hyprland.homeManagerModules.default
	            inputs.anyrun.homeManagerModules.default
            ];
          };
        };
        nixpkgs = {
          overlays = [ self.overlays.default ];
        };
      }
    ];
  };
}
