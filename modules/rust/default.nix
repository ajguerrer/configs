{ config, pkgs, user, ... }:
{
  users.users.${user}.packages = with pkgs; [
    rustup
  ];

  environment = {
    systemPackages = with pkgs; [
      clang
      libclang
      file
      gnumake
      pkg-config
      openssl.dev
    ];

    variables = {
      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
      LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
      BINDGEN_EXTRA_CLANG_ARGS = ''
      -I"${pkgs.linuxHeaders}/include"
      -I"${pkgs.libclang.lib}/lib/clang/${pkgs.libclang.version}/include"
      '';
    };
  };
}