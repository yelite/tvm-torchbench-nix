{ fetchFromGitHub }:
let
  commit-rev = "9b9bcbc";
  src =
    fetchFromGitHub
      {
        owner = "pytorch";
        repo = "benchmark";
        rev = commit-rev;
        fetchSubmodules = true;
        fetchLFS = true;
        sha256 = "sha256-+SZ2HBTJaLGDahvaqAhcLVSq/wZo+HQd/Q0fGbL8iKE=";
        name = "torchbench-src";
        postFetch = ''
          pushd $out/torchbenchmark/data
          mkdir -p .data

          cd .data
          for f in ../*.tar.gz; do
              unpackFile $f
          done

          popd
        '';
      };
in
src
