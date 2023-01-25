{ lib
, stdenv
}:
python-self: python-super:
let
  base = python-self.callPackage ./base.nix { };
in
{
  torchbench-base = base.withModels "base" [ ];
  torchbench-full = base.withModels "full" [
    ./model-supports/BERT_pytorch.nix
  ];
}
