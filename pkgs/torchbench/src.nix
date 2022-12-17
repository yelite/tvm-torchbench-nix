{ fetchFromGitHub }:

let
  commit = "b662a6fb";
in
fetchFromGitHub {
  owner = "pytorch";
  repo = "benchmark";
  rev = commit;
  fetchSubmodules = true;
  fetchLFS = true;
  sha256 = "sha256-zPvcia4TtbuL3euEZP8HhU2/SRkcoqZYFuhR/6TqiCc=";
  name = "torchbench-src";
}
