{
  description = "ajguerrer's NixOS and Home-Manager flake";

  nixConfig = { };
 
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    let 
      user = "andrew";
      selfPkgs = import ./pkgs;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = ["x86_64-linux"];
      imports = [
      	inputs.flake-root.flakeModule
      ];

      perSystem = { config, inputs', pkgs, system, lib, ... }:

      let
        pkgs = import nixpkgs {
	        inherit system;
          overlays = [
              self.overlays.default
          ];
	      };
      in 
      {
        devShells.default = pkgs.mkShell {
	        packages = [
	          pkgs.alejandra
	          pkgs.git
	        ];
	        name = "dots";
	        DIRENV_LOG_FORMAT ="";
	        inputsFrom = [config.flake-root.devShell];
	      };
        formatter = pkgs.alejandra;
      };
      flake = {
        overlays.default = selfPkgs.overlay;
        nixosConfigurations = (
	        import ./hosts {
	          system = "x86_64-linux";
	          inherit nixpkgs self inputs user;
	        }
        );
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/hyprland";
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
     
    anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
      "https://anyrun.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
    ];
  };
}
