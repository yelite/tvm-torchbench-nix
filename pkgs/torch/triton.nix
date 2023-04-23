{ stdenv
, buildPythonPackage
, fetchurl
, isPy37
, isPy38
, isPy39
, isPy310
, python
, pythonRelaxDepsHook
, filelock
}:

let
  pyVerNoDot = builtins.replaceStrings [ "." ] [ "" ] python.pythonVersion;
  srcs = import ./binary-hashes.nix "torchtriton" version;
  unsupported = throw "Unsupported system for torchtrion";
  version = "2.0.0";
in
buildPythonPackage {
  inherit version;

  pname = "torchtriton";

  format = "wheel";

  disabled = !(isPy37 || isPy38 || isPy39 || isPy310);

  src = fetchurl srcs."${stdenv.system}-${pyVerNoDot}" or unsupported;

  nativeBuildInputs = [
    pythonRelaxDepsHook
  ];

  propagatedBuildInputs = [
    filelock
  ];

  pythonRemoveDeps = [
    "torch" # avoid circular dependency
    "cmake" # this is build time dependency
  ];
}
