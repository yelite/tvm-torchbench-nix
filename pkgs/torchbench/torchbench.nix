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
    cp -r $src/components $out/${python.sitePackages}/
    cp -r $src/utils $out/${python.sitePackages}/
    cp -r $src/torchbenchmark $out/${python.sitePackages}/
    
    mkdir $out/bin

    echo "#!/usr/bin/env python" >> $out/bin/torchbench_test
    cat $src/test.py >> $out/bin/torchbench_test

    echo "#!/usr/bin/env python" >> $out/bin/torchbench_test_bench
    cat $src/test_bench.py >> $out/bin/torchbench_test_bench

    chmod +x $out/bin/*
  '';

  disabled = !(isPy37 || isPy38 || isPy39 || isPy310);

  propagatedBuildInputs = [
    torchbench-base
    torchbench-model-bert-pytorch
  ];
}
