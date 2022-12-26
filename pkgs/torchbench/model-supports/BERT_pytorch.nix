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

  checkInputs = [
    torchbench-base
  ];

  installCheckPhase = ''
    runHook preInstallCheck

    ${python.interpreter} ${torchbench-src}/run.py BERT_pytorch

    runHook postInstallCheck
  '';

}
