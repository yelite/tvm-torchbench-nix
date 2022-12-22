{ buildPythonPackage
, python

, tqdm
, numpy

, torchbench-base
, torchbench-src
}:

buildPythonPackage {
  pname = "torchbench-model-bert-pytorch";
  version = torchbench-src.rev or "unknown";

  format = "other";
  dontUnpack = true;
  dontInstall = true;

  propagatedBuildInputs = [
    tqdm
    numpy
  ];
}
