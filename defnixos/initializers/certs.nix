lib: lib.composable [ "build-support" "pkgs" ] (

build-support@{ write-script }:

pkgs@{ openssl, wait-for-file, sh, coreutils, execve }:

let
  # Should this be a param?
  x509-directory = "/etc/x509";

  subject =
    "/C=SG/ST=Singapore/O=Zalora/OU=DevOps/CN=$name-$id/emailAddress=it-services@zalora.com";

  conf = builtins.toFile "openssl-req.conf" ''
    [ req ]
    req_extensions = v3_ca
    distinguished_name = req_distinguished_name

    [ req_distinguished_name ]

    [ v3_ca ]
    subjectAltName = email:copy
  '';

  script = write-script "generate-x509" ''
    #!${sh} -e
    name=$1
    user=$2
    if [ ! -f ${x509-directory}/$name.crt ]; then
      mkdir -p ${x509-directory}

      oldmask=`umask`
      umask 0077
      ${openssl}/bin/openssl genrsa -out ${x509-directory}/$name.pem 2048
      chown $user ${x509-directory}/$name.pem
      umask $oldmask

      id=`cat /etc/machine-id`
      ${openssl}/bin/openssl req -out ${x509-directory}/$name.csr -new -subj ${subject} \
        -key ${x509-directory}/$name.pem -config ${conf}

      ${wait-for-file} ${x509-directory}/$name.crt
    fi
    if [ ! -f ${x509-directory}/$name.p12 ]; then
      umask 0077
      ${openssl}/bin/openssl pkcs12 -export -passout pass:fakepass \
        -in ${x509-directory}/$name.crt -inkey ${x509-directory}/$name.pem \
        -out ${x509-directory}/$name.p12
      chown $user ${x509-directory}/$name.p12
      umask $oldmask
    fi
  '';
in

# An initializer to create a cert/keypair for a service

{ service-name        # The name of the service using the cert
, user ? service-name # The user who needs access to the cert
}:

execve "${service-name}-x509-generation" {
  filename = script;

  argv = [ "generate-x509" service-name user ];

  envp =  { PATH = "${coreutils}/bin"; };
})
