{ tqdm
, numpy
}:

{
  models = [
    "BERT_pytorch"
  ];

  extraPythonPackages = [
    tqdm
    numpy
  ];
}
