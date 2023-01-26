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
        sha256 = "sha256-GH+2m84kOcs4iqxr/wjpd5BnnfMEbGjp+iTq6ZsFRGE=";
        name = "torchbench-src";
      };
in
src
