#!/bin/sh

progname=$(basename $0)
script_name=$1

help() {
    echo "Usage: ${progname} (test|test_bench|run|run_sweep|run_benchmark) ..."
}

case $script_name in
    "" | "-h" | "--help")
        help
        ;;
    *)
        shift
        @python@ @torchbenchRoot@/${script_name}.py $@
        ;;
esac

