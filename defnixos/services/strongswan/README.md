strongswan
===========

A service to allow incoming ipsec connections from any host with a cert
signed by the right CA and on-demand outgoing ipsec connections to the
hosts in outgoing-hosts.

Arguments
----------

* `outgoing-hosts`: A list of hosts to make on-demand connections to (default
  `[]`)
* `ca`: The root CA certificate that is used to authenticate incoming connections
* `service-name`: The name of the service in the global service namespace
  (default `strongswan`)
* `cert-archive`: A pkcs12 archive containing a key/cert pair signed by the CA.
  The archive must be protected with the passphrase "fakepass" due to a
  limitation in `strongswan`'s pkcs12 handling.
