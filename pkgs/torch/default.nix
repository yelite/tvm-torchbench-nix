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
  pytorch-bin = python-self.torch-bin;
  torch-bin = python-super.torch-bin.overridePythonAttrs
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
        unsupported = throw "Unsupported system for torchvision-bin";
        wheels = import ./binary-hashes.nix "torchvision" version;
      in
      {
        inherit version;
        src = fetchurl wheels.${systemPyVersionTag} or unsupported;
        postFixup = lib.optionalString stdenv.isLinux old.postFixup;
        meta = old.meta // (with lib;
          {
            platforms = platforms.linux ++ platforms.darwin;
          });
      });

  torchaudio-bin = python-super.torchaudio-bin.overridePythonAttrs
    (old:
      let
        version = "0.14.0.dev20221214";
        unsupported = throw "Unsupported system for torchaudio-bin";
        wheels = import ./binary-hashes.nix "torchaudio" version;
      in
      {
        inherit version;
        src = fetchurl wheels.${systemPyVersionTag} or unsupported;
        postFixup = lib.optionalString stdenv.isLinux old.postFixup;
        meta = old.meta // (with lib;
          {
            platforms = platforms.linux ++ platforms.darwin;
          });
      });

  torchtriton-bin = python-self.callPackage ./torchtriton.nix { };
  torchtext-bin = python-self.callPackage ./torchtext.nix { };
  torchdata-bin = python-self.callPackage ./torchdata.nix { };
}
