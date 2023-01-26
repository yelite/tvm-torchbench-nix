{ symlinkJoin
, callPackage
}:
let
  torchvision-weights = callPackage ./torchvision { };
in
symlinkJoin {
  name = "torchbench-weights";
  paths = [
    torchvision-weights
  ];
  postBuild = ''
    mkdir -p $out/nix-support
    substituteAll ${./setup-hook.sh} $out/nix-support/setup-hook
  '';
}
