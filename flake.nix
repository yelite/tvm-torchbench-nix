{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
  };

  outputs = { self, utils, nixpkgs, ... }@inputs: utils.lib.mkFlake {
    inherit self inputs;

    supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];

    channels.nixpkgs = {
      input = nixpkgs;
      config = {
        allowUnfree = true;
      };
      overlaysBuilder = channels: [
        self.overlay
      ];
    };

    overlay = import ./pkgs;
    overlays = utils.lib.exportOverlays {
      inherit (self) pkgs inputs;
    };

    outputsBuilder = channels:
      let
        pkgs = channels.nixpkgs;
        inherit (pkgs) stdenv lib;
        overlay-pkgs = utils.lib.exportPackages self.overlays channels;
        pythonLib = pkgs.callPackage ./python.nix { };
        benchmark-python-env = pythonLib.mkBenchmarkPythonEnv {
          python = pkgs.python310;
        };
      in
      {
        packages = overlay-pkgs // {
          inherit benchmark-python-env;
        } // (pythonLib.extractOverriddenPackages benchmark-python-env "benchmark-python-env");

        devShell = pkgs.mkShell {
          name = "tvm-torchbench-shell";
          packages = (with pkgs; [
            git-lfs
            cmake
            benchmark-python-env
          ]);
          shellHook = ''
            export TVM_HOME=$(pwd)/../tvm-nix/tvm
            export PYTHONPATH="$TVM_HOME/python:$PYTHONPATH"
          '';
        };
      };
  };
}
