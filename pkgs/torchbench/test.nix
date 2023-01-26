{ runCommand
, torchbench
, models
,
}:

runCommand "${torchbench.pname}-tests"
{
  buildInputs = [ torchbench ];
  meta.timeout = 10 * builtins.length models;
}
  ''
    for model in ${toString models}; do
      echo "testing $model"
      ${torchbench}/bin/torchbench run $model --bs 1
    done

    touch $out
  ''
