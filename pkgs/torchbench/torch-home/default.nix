{ symlinkJoin
, callPackage
, lndir
}:
let
  torchvision-weights = callPackage ./torchvision { };
in
symlinkJoin {
  name = "torchbench-torch-home";
  paths = [
    torchvision-weights
  ];

  inherit lndir;
  postBuild = ''
    mkdir -p $out/nix-support
    substituteAll ${./setup-hook.sh} $out/nix-support/setup-hook

    mkdir -p $out/bin
    substituteAll ${./install_benchmark_torch_hub_data.sh} $out/bin/install_benchmark_torch_hub_data
    chmod +x $out/bin/*
  '';
}
