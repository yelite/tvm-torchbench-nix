# Dummy base package to p
{ stdenv
, buildPythonPackage
, fetchFromGitHub
, isPy37
, isPy38
, isPy39
, isPy310
, python

  # Python Packages
, pytorch-bin
, torchvision-bin
, torchtext-bin
, torchaudio-bin
, beautifulsoup4
, patch
, py-cpuinfo
, distro
, pytest
, pytest-benchmark
, requests
, tabulate
  # , pytorch-image-models  doesnt exist # TODO: TorchBench pins it to 644665b
, transformers  # TODO: TorchBench pins it to 4.20.1
, psutil
, pyyaml
, numpy  # TODO: TOrchBench pins it to 1.21.2
  # , kornia  doesn't exist https://github.com/kornia/kornia
, scipy

  # From ./src.nix
, src
}:

buildPythonPackage {
  version = src.rev or "unknown";

  pname = "torchbench-base";

  format = "other";

  dontUnpack = true;
  dontInstall = true;

  disabled = !(isPy37 || isPy38 || isPy39 || isPy310);

  propagatedBuildInputs = [
    pytorch-bin
    torchvision-bin
    torchtext-bin
    torchaudio-bin
    beautifulsoup4
    patch
    py-cpuinfo
    distro
    pytest
    pytest-benchmark
    requests
    tabulate
    transformers # TODO: TorchBench pins it to 4.20.1
    psutil
    pyyaml
    numpy # TODO: TOrchBench pins it to 1.21.2
    scipy

    # submitit  Only used in distributed benchmark
    # MokeyType  Only used for dev
    # kornia  Only used for drq model
    # accelerate  Only used for e2e models
    # iopath  Not used 
  ];
}




