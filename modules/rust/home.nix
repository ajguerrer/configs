{ config, pkgs, user, ... }:
{
  home.packages = with pkgs; [
    clang
    llvmPackages.bintools
    rustup
  ];

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin"
  ];
}