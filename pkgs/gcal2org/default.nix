{ stdenv, fetchurl, unzip, jre
}:

stdenv.mkDerivation rec {
  name = "gcal2org-${version}";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/dtulig/gcal2org/releases/download/0.1.0/gcal2org-${version}-standalone.zip";
    sha256 = "0wlrdfkffgmx077k8205jrr9li0f9vgw51aqhyyiqbsh4mhx5cm3";
  };

  sourceRoot = "gcal2org";

  buildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp -v $src $out/lib/gcal2org.jar

    cat > $out/bin/gcal2org << EOF
    #!/bin/sh
    exec ${jre}/bin/java -jar $out/lib/gcal2org.jar \$@
    EOF

    chmod +x $out/bin/gcal2org
  '';

  phases = "unpackPhase installPhase";

  meta = {
    description = "A command line utility using the Google Calendar API to pull down calendar events and outputting them in a format that org-mode understands.";
    homepage = "https://github.com/dtulig/gcal2org";
    license = "EPL";
    #maintainers = [ stdenv.lib.maintainers.dtulig ];
  };
}