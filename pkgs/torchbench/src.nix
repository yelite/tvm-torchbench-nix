{ fetchFromGitHub }:

fetchFromGitHub {
  owner = "pytorch";
  repo = "benchmark";
  rev = "7c2d3eb0e2bb238b97133192abfc02104b1b4b6e";
  fetchSubmodules = true;
  fetchLFS = true;
  sha256 = "sha256-RKbzTr1S6x5TF3RaeUdEQuqVBAt6uatKi0BuNXbwiHA=";
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
}
