{ numpy
, opencv4
, pillow
, pycocotools
, tqdm
, matplotlib
, tensorboard
}:

{
  models = [
    "yolov3"
  ];

  extraPythonPackages = [
    numpy
    opencv4
    pillow
    pycocotools
    tqdm
    matplotlib
    tensorboard
  ];
}


