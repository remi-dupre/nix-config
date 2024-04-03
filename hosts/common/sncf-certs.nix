{ ... }:

{
  environment.variables = {
    # This should make most Python libraries happy
    REQUESTS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
  };

  security.pki.certificateFiles = [
    # Deprecated
    ../certs/AC_Racine_SNCF.cer
    ../certs/AC_Infrastructure_SNCF.cer
    # 2023 - Prod
    ../certs/AC_RACINE_SNCF_2023.cer
    ../certs/AC_INFRASTRUCTURE_SNCF_2023.cer
    # 2023 - Preprod
    ../certs/AC_RACINE_SNCF_2023-ppd.cer
    ../certs/AC_PROXY_SNCF_2023-ppd.cer
    ../certs/AC_MACHINES_SNCF_2023-ppd.cer
    ../certs/AC_UTILISATEURS_SNCF_2023-ppd.cer
    ../certs/AC_INFRASTRUCTURE_SNCF_2023-ppd.cer
  ];
}
