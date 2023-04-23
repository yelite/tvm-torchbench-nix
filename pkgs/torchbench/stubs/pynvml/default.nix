{ python
, buildPythonPackage
, pynvml
}:

buildPythonPackage {
  pname = "pynvml-stub";
  version = pynvml.version;
  src = ./src;

  format = "other";
  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/${python.sitePackages}/pynvml
    cp -r $src $out/${python.sitePackages}/pynvml
  '';
}
