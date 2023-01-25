{ stdenv
, buildPythonPackage
, fetchFromGitHub
, callPackage
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
}:

let
  commit-rev = "b662a6fb";
  src = fetchFromGitHub
    {
      owner = "pytorch";
      repo = "benchmark";
      rev = commit-rev;
      fetchSubmodules = true;
      fetchLFS = true;
      sha256 = "sha256-zPvcia4TtbuL3euEZP8HhU2/SRkcoqZYFuhR/6TqiCc=";
      name = "torchbench-src";
    };
  base = buildPythonPackage
    {
      pname = "torchbench";
      version = commit-rev;
      inherit src;

      format = "other";

      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/${python.sitePackages}
        ln -s $src/components $out/${python.sitePackages}/
        ln -s $src/utils $out/${python.sitePackages}/
        ln -s $src/torchbenchmark $out/${python.sitePackages}/
    
        mkdir -p $out/share/script
        for f in test test_bench run run_sweep run_benchmark; do
          cp $src/''${f}.py $out/share/script/
        done

        mkdir $out/bin

        substitute ${./torchbench.sh} $out/bin/torchbench \
          --subst-var-by torchbenchRoot $out/share/script

        chmod +x $out/bin/*
      '';

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

      passthru = {
        withModels = suffix: modelSupports:
          let
            inherit (builtins) concatMap map isFunction isPath removeAttrs;
            maybeCallPackage = m: if (isFunction m) || (isPath m) then callPackage m { } else m;
            injectedModelSupports = map maybeCallPackage modelSupports;
            extraPythonPackages = concatMap (m: m.extraPythonPackages or[ ]) injectedModelSupports;
          in
          base.overridePythonAttrs (old: {
            pname = old.pname + "-${suffix}";
            propagatedBuildInputs = old.propagatedBuildInputs ++ extraPythonPackages;

            passthru = removeAttrs old.passthru [ "withModels" ];
            meta = old.meta // { broken = false; };
          });
      };

      meta = {
        # This package is not supposed to be used directly. 
        # Use packageTorchBench to create the final package.
        broken = true;
      };
    };
in
base
