{ lib
, stdenv
}:
python-self: python-super:
let
  inherit (python-self) callPackage toPythonModule;
  base = callPackage ./base.nix { };
in
{
  torchbench-src = toPythonModule (callPackage ./src.nix { });
  torchbench-weights = toPythonModule (callPackage ./weights { });

  torchbench-base = base.withModels "base" [ ];
  torchbench-full = base.withModels "full" [
    ./model-supports/BERT_pytorch.nix
    ./model-supports/pytorch_unet.nix
  ];
}
