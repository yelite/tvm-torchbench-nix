{ numpy
, pillow
  # , wandb
, tqdm
, matplotlib
}:

{
  models = [
    "pytorch_unet"
  ];

  extraPythonPackages = [
    numpy
    pillow
    # Wait for https://github.com/NixOS/nixpkgs/pull/208232 getting into unstable
    # wandb
    tqdm
    matplotlib
  ];
}
