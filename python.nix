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
        newPython = python.override {
          packageOverrides = pythonPackageOverrides;
        };
        pythonEnv = newPython.withPackages
          (ps: with ps; [
            pytorch-bin
            torchvision-bin
            torchtext-bin
            torchbench-full
            pytest
          ]);
      in
      pythonEnv.overrideAttrs
        (oldAttrs: {
          passthru = oldAttrs.passthru // { basePython = newPython; };
        });

  extractOverriddenPackages = pythonEnv: packagePrefix:
    assert assertMsg (pythonEnv ? basePython)
      "extractOverriddenPackages can only be used with python env from mkBenchmarkPythonEnv";
    let
      inherit (builtins) foldl';
      pythonPackages = pythonEnv.basePython.pkgs;
      getPackage = name: {
        "${packagePrefix}-${name}" = pythonPackages.${name};
      };
      overriddenPackages = map getPackage overriddenPackageNames;
    in
    foldl' (a: b: a // b) { } overriddenPackages;
}
