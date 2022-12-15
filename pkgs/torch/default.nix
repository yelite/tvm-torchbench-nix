{ lib
, fetchurl
, stdenv
}:

python-self: python-super:
let
  pyVerNoDot = builtins.replaceStrings [ "." ] [ "" ] python-super.python.pythonVersion;
  systemPyVersionTag = "${stdenv.system}-${pyVerNoDot}";
in
{
  pytorch-bin = python-super.pytorch-bin.overridePythonAttrs
    (old:
      let
        version = "2.0.0.dev20221214";
        unsupported = throw "Unsupported system for torch";
        wheels = import ./binary-hashes.nix "torch" version;
      in
      {
        inherit version;
        src = fetchurl wheels.${systemPyVersionTag} or unsupported;

        propagatedBuildInputs = old.propagatedBuildInputs ++ [
          python-super.networkx
          python-super.sympy
        ] ++ lib.optionals stdenv.isLinux [
          python-self.torchtriton-bin
        ];
      });

  torchvision-bin = python-super.torchvision-bin.overridePythonAttrs
    (old:
      let
        version = "0.15.0.dev20221214";
        unsupported = throw "Unsupported system for torch";
        wheels = import ./binary-hashes.nix "torchvision" version;
      in
      {
        inherit version;
        src = fetchurl wheels.${systemPyVersionTag} or unsupported;
      });

  torchtriton-bin = python-self.callPackage ./torchtriton.nix { };
  torchtext-bin = python-self.callPackage ./torchtext.nix { };
  torchdata-bin = python-self.callPackage ./torchdata.nix { };
}
