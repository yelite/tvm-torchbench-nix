{ lib
, stdenv
, callPackage
}:

let
  src = callPackage ./src.nix { };
in

python-self: python-super:
{
  torchbench = python-self.callPackage ./base.nix { inherit src; };
  torchbench-base = python-self.callPackage ./base.nix { inherit src; };
  torchbench-model-bert-pytorch = python-self.callPackage ./model-supports/BERT_pytorch.nix { inherit src; };
}
