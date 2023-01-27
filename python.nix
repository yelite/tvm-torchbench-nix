{ lib
, callPackage
,
}:

let
  inherit (lib.asserts) assertMsg;
  pythonPackageOverrides = lib.composeManyExtensions [
    (callPackage ./pkgs/torch { })
    (callPackage ./pkgs/torchbench { })
  ];
  overriddenPackageNames = builtins.attrNames (pythonPackageOverrides null null);
in
{
  inherit pythonPackageOverrides;

  mkBenchmarkPythonEnv =
    { python
    ,
    }:
      assert python.isPy3;
      let
        basePython = python.override {
          packageOverrides = pythonPackageOverrides;
        };
        benchmarkPythonEnv = basePython.buildEnv.override
          {
            python = basePython;
            extraLibs = with basePython.pkgs; [
              torchbench-full
              pytest
            ];
          };
        patchShellWithTorchHome = shellEnv: shellEnv.overrideAttrs
          (oldAttrs: {
            nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
              # To get the TORCH_HOME variable
              benchmarkPythonEnv.pkgs.torchbench-torch-home
            ];
          });
      in
      benchmarkPythonEnv.overrideAttrs
        (oldAttrs: {
          passthru = oldAttrs.passthru // {
            env = patchShellWithTorchHome oldAttrs.passthru.env;
          };
        });

  extractOverriddenPackages = pythonEnv: packagePrefix:
    let
      inherit (builtins) foldl';
      pythonPackages = pythonEnv.pkgs;
      getPackage = name: {
        "${packagePrefix}-${name}" = pythonPackages.${name};
      };
      overriddenPackages = map getPackage overriddenPackageNames;
    in
    foldl' (a: b: a // b) { } overriddenPackages;
}
