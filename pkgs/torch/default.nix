{ fetchurl
, stdenv
,
}:

python-self: python-super:
let
  inherit (python-super) python;
in
{
  torchtriton-bin = python-super.callPackage ./torchtriton.nix { };

  pytorch-bin = python-super.pytorch-bin.overridePythonAttrs
    (old:
      let
        pyVerNoDot = builtins.replaceStrings [ "." ] [ "" ] python-super.python.pythonVersion;
        version = "2.0.0.dev20221213";
        unsupported = throw "Unsupported system";
        wheels = import ./binary-hashes.nix version;
      in
      {
        inherit version;
        src = fetchurl wheels."${stdenv.system}-${pyVerNoDot}" or unsupported;

        propagatedBuildInputs = old.propagatedBuildInputs ++ [
          python-super.networkx
          python-super.sympy
          python-self.torchtriton-bin
        ];
      });
}
