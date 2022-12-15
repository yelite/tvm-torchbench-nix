{ stdenv
, buildPythonPackage
, fetchurl
, isPy37
, isPy38
, isPy39
, isPy310
, python
, pytorch-bin
, requests
, tqdm
, torchdata-bin
}:

let
  pyVerNoDot = builtins.replaceStrings [ "." ] [ "" ] python.pythonVersion;
  srcs = import ./binary-hashes.nix "torchtext" version;
  unsupported = throw "Unsupported system for torchtext";
  version = "0.15.0.dev20221214";
in
buildPythonPackage {
  inherit version;

  pname = "torchtext";

  format = "wheel";

  disabled = !(isPy37 || isPy38 || isPy39 || isPy310);

  src = fetchurl srcs."${stdenv.system}-${pyVerNoDot}" or unsupported;

  propagatedBuildInputs = [
    pytorch-bin
    torchdata-bin
    requests
    tqdm
  ];

  pythonImportsCheck = [ "torchtext" ];
}
