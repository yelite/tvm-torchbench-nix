{ numpy
, pillow
, wandb
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
    wandb
    tqdm
    matplotlib
  ];
}
