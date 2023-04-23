{ lib
, stdenv
}:
python-self: python-super:
let
  inherit (python-self) callPackage toPythonModule;
  inherit (builtins) readDir attrNames filter map elem length;
  base = callPackage ./base.nix { };
  allModelSupports = attrNames (readDir ./model-supports);
  makeTorchBench = { tag, includes ? null, excludes ? [ ] }: (
    assert includes == null || length excludes == 0;
    let
      modelSupportNamesToInclude =
        if includes == null
        then filter (m: !(elem m excludes)) allModelSupports
        else includes;
      modelSupports = map (m: ./model-supports + "/${m}") modelSupportNamesToInclude;
    in
    base.withModels tag modelSupports
  );
in
{
  torchbench-src = toPythonModule (callPackage ./src.nix { });
  torchbench-torch-home = toPythonModule (callPackage ./torch-home { });

  torchbench-base = makeTorchBench {
    tag = "base";
    includes = [ ];
  };
  torchbench-full = makeTorchBench {
    tag = "full";
  };

  pynvml-stub = callPackage ./stubs/pynvml { };
}
