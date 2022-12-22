{ lib
, stdenv
}:


python-self: python-super:
{
  torchbench = python-self.callPackage ./torchbench.nix { };
  torchbench-src = python-self.callPackage ./src.nix { };
  torchbench-base = python-self.callPackage ./base.nix { };
  torchbench-model-bert-pytorch = python-self.callPackage ./model-supports/BERT_pytorch.nix { };
}
