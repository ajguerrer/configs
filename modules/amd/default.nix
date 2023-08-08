{ config, pkgs, ... }:
{
  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime

      amdvlk
      driversi686Linux.amdvlk
    ];
    driSupport = true;
    driSupport32Bit = true;
  };
}
