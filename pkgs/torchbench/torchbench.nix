{ stdenv
, buildPythonPackage
, fetchFromGitHub
, isPy37
, isPy38
, isPy39
, isPy310
, python

, torchbench-src
, torchbench-base
, torchbench-model-bert-pytorch
}:

buildPythonPackage {
  pname = "torchbench";
  version = torchbench-src.rev or "unknown";
  src = torchbench-src;

  format = "other";

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/${python.sitePackages}
    cp -r $src/torchbenchmark $out/${python.sitePackages}/
  '';

  disabled = !(isPy37 || isPy38 || isPy39 || isPy310);

  propagatedBuildInputs = [
    torchbench-base
    torchbench-model-bert-pytorch
  ];
}
