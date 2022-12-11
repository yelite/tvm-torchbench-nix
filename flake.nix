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
        overlay-pkgs = utils.lib.exportPackages self.overlays channels;
        tvm-torchbench-python-env = pkgs.python3.withPackages (python-packages: with python-packages; [
          pandas
          requests
        ]);
        inherit (pkgs) stdenv lib;
      in
      {
        packages = overlay-pkgs // {
          inherit tvm-torchbench-python-env;
        };
        devShell = pkgs.mkShell {
          name = "tvm-torchbench-shell";
          packages = (with pkgs; [
            git-lfs
            cmake
            tvm-torchbench-python-env
          ]);
          shellHook = ''
            export TVM_HOME=$(pwd)/../tvm-nix/tvm
            export PYTHONPATH="$TVM_HOME/python:$PYTHONPATH"
          '';
        };
      };
  };
}
