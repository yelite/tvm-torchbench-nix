{ buildPythonPackage
, python

, torchbench-base

  # From ../src.nix
, src
}:

buildPythonPackage {
  pname = "torchbench-model-bert-pytorch";
  version = src.rev or "unknown";
  inherit src;

  dontInstall = true;
}
