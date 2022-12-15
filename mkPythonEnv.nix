{ lib
, callPackage
,
}:

{ python
,
}:
assert python.isPy3;
let
  packageOverrides = lib.composeManyExtensions [
    (callPackage (import ./pkgs/torch) { })
  ];
  newPython = python.override { inherit packageOverrides; };
in
newPython.withPackages (ps: with ps; [
  pytorch-bin
  torchvision-bin
  torchtext-bin
])
