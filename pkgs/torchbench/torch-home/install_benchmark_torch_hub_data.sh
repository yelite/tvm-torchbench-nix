#!/bin/sh

torch_home=${TORCH_HOME}
if [ -z $torch_home ]; then
    torch_home=${XDG_CACHE_HOME:-$HOME/.cache}/torch
fi

mkdir -p ${torch_home}/hub

@lndir@/bin/lndir -silent @out@/share/torch/ ${torch_home}/
echo "Created symbolic links of Torch hub data to ${torch_home}"
