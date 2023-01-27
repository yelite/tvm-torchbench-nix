{ stdenvNoCC
, cacert
, python
, toPythonModule

, torchbench-src

, torchvision-bin
, pytorch-bin
, psutil
, numpy
}:

toPythonModule (stdenvNoCC.mkDerivation {
  pname = "torchbench-torchvision-weights";
  version = torchvision-bin.version;

  nativeBuildInputs = [
    python
    numpy
    psutil
    torchvision-bin
    pytorch-bin
    cacert
  ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/share/torch
    export TORCH_HOME=$out/share/torch;

    export PYTHONPATH=${torchbench-src}:$PYTHONPATH;
    python ${./download_torchvision_weights.py}
  '';


  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-6MSEf7MK+XaCSwoKRSoJ/EvyRs8nWn5emq3gIYbfX0c=";
})
