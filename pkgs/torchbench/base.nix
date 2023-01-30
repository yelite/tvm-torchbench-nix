{ stdenv
, lib
, runtimeShell
, buildPythonPackage
, fetchFromGitHub
, callPackage
, isPy37
, isPy38
, isPy39
, isPy310
, python

, torchbench-src
, torchbench-torch-home

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
  commit-rev = "9b9bcbc";

  base = buildPythonPackage
    {
      pname = "torchbench";
      version = torchbench-src.rev;
      src = torchbench-src;

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

        substitute ${./bin/torchbench.sh} $out/bin/torchbench \
          --subst-var-by torchbenchRoot $out/share/script \
          --subst-var-by python ${python}/bin/python \

        patchShebangs --host $out/bin/torchbench

        chmod +x $out/bin/*
      '';

      disabled = !(isPy37 || isPy38 || isPy39 || isPy310);

      propagatedBuildInputs = [
        pytorch-bin
        torchvision-bin
        torchtext-bin
        torchaudio-bin

        torchbench-torch-home

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
        supportedModels = [
          "resnet152"
          "resnet18"
          "resnet50"
          "resnet50_quantized_qat"
          "resnext50_32x4d"
          "vgg16"
          "alexnet"
          "mnasnet1_0"
          "densenet121"
          "mobilenet_v2"
          "mobilenet_v2_quantized_qat"
          "mobilenet_v3_large"
          "squeezenet1_1"
          "shufflenet_v2_x1_0"
        ];

        disabledModels = [
          "Background_Matting" # Training only

          "attention_is_all_you_need_pytorch"
          "DALLE2_pytorch"
          "dcgan"
          "demucs"
          "detectron2_fasterrcnn_r_101_c4"
          "detectron2_fasterrcnn_r_101_dc5"
          "detectron2_fasterrcnn_r_101_fpn"
          "detectron2_fasterrcnn_r_50_c4"
          "detectron2_fasterrcnn_r_50_dc5"
          "detectron2_fasterrcnn_r_50_fpn"
          "detectron2_fcos_r_50_fpn"
          "detectron2_maskrcnn"
          "detectron2_maskrcnn_r_101_c4"
          "detectron2_maskrcnn_r_101_fpn"
          "detectron2_maskrcnn_r_50_c4"
          "detectron2_maskrcnn_r_50_fpn"
          "dlrm"
          "doctr_det_predictor"
          "doctr_reco_predictor"
          "drq"
          "fambench_xlmr"
          "fastNLP_Bert"
          "functorch_dp_cifar10"
          "functorch_maml_omniglot"
          "hf_Albert"
          "hf_Bart"
          "hf_Bert"
          "hf_Bert_large"
          "hf_BigBird"
          "hf_DistilBert"
          "hf_GPT2"
          "hf_GPT2_large"
          "hf_Longformer"
          "hf_Reformer"
          "hf_T5"
          "hf_T5_base"
          "hf_T5_large"
          "LearningToPaint"
          "lennard_jones"
          "maml"
          "maml_omniglot"
          "moco"
          "nvidia_deeprecommender"
          "opacus_cifar10"
          "phlippe_densenet"
          "phlippe_resnet"
          "pyhpc_equation_of_state"
          "pyhpc_isoneutral_mixing"
          "pyhpc_turbulent_kinetic_energy"
          "pytorch_CycleGAN_and_pix2pix"
          "pytorch_stargan"
          "pytorch_struct"
          "soft_actor_critic"
          "speech_transformer"
          "Super_SloMo"
          "tacotron2"
          "timm_efficientdet"
          "timm_efficientnet"
          "timm_nfnet"
          "timm_regnet"
          "timm_resnest"
          "timm_vision_transformer"
          "timm_vision_transformer_large"
          "timm_vovnet"
          "tts_angular"
          "vision_maskrcnn"
        ];

        withModels = tag: modelSupports:
          let
            inherit (builtins) concatMap map isFunction isPath removeAttrs listToAttrs;
            maybeCallPackage = m: (
              if (isFunction m) || (isPath m)
              then callPackage m { }
              else m
            );
            injectedModelSupports = map maybeCallPackage modelSupports;
            extraPythonPackages = concatMap (m: m.extraPythonPackages or [ ]) injectedModelSupports;
            additionalSupportedModels = concatMap (m: m.models) injectedModelSupports;
            supportedModels = lib.lists.unique (base.passthru.supportedModels ++ additionalSupportedModels);
            makeModelTest = models:
              callPackage ./test.nix {
                inherit models;
                torchbench = final;
              };
            final = base.overridePythonAttrs
              (old: {
                pname = old.pname + "-${tag}";
                propagatedBuildInputs = old.propagatedBuildInputs ++ extraPythonPackages;
                passthru = (removeAttrs old.passthru [ "withModels" ]) // {
                  inherit supportedModels;
                  tests = {
                    allModels = makeModelTest supportedModels;
                  } // listToAttrs (map
                    (model: {
                      name = model;
                      value = makeModelTest [ model ];
                    })
                    supportedModels
                  );
                };

                meta = old.meta // { broken = false; };
              });
          in
          final;
      };

      meta = {
        # This package is not supposed to be used directly. 
        # Use packageTorchBench to create the final package.
        broken = true;
      };
    };
in
base
