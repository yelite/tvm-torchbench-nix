{ stdenv
, buildPythonPackage
, fetchurl
, isPy37
, isPy38
, isPy39
, isPy310
, python
, pytestCheckHook
, pytorch-bin
, requests
, portalocker
}:

let
  pyVerNoDot = builtins.replaceStrings [ "." ] [ "" ] python.pythonVersion;
  srcs = import ./binary-hashes.nix "torchdata" version;
  unsupported = throw "Unsupported system for torchdata";
  version = "0.6.0.dev20221214";
in
buildPythonPackage {
  inherit version;

  pname = "torchdata";

  format = "wheel";

  disabled = !(isPy37 || isPy38 || isPy39 || isPy310);

  src = fetchurl srcs."${stdenv.system}-${pyVerNoDot}" or unsupported;

  propagatedBuildInputs = [
    pytorch-bin
    requests
    portalocker
  ];
}
