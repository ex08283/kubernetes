openssl genrsa -out adam.key 2048
# This command generates a 2048-bit RSA private key and saves it to a file named 'ca.key'.
# This key will be used to sign the certificate authority (CA) certificate.
# The private key is essential for creating a self-signed CA certificate, which can then be used to sign other certificates.
# The 'ca.key' file should be kept secure, as it is used to establish trust for the certificates issued by this CA.

openssl req -new -key adam.key -out adam.csr -subj "/CN=Adam"
# the CN is important as it identifies the user in Kubernetes when using client certificates for authentication.
# the CN sets the username in Kubernetes RBAC
# This command creates a Certificate Signing Request (CSR) named 'adam.csr' using the
# private key 'ca.key'. The '-subj' option specifies the subject of the certificate,
# where 'CN' is the Common Name (e.g., the name of the entity the certificate is for)
# and 'O' is the Organization. In this case, the CN is set to 'Adam' and the organization to 'MyOrg'.
# The CSR contains information about the entity requesting the certificate and is used to apply for a digital certificate from a Certificate Authority (CA).
# The CSR does not contain the private key, ensuring that the private key remains secure.

 cat adam.csr | base64 | tr -d "\n"
# will encoded the csr file to be used in the request field and remove new lines

k apply -f adam.yaml
# to create the csr in the cluster

k get csr
# to see the list of csr in the cluster, it will be pending until approved
k delete csr <name>
# to delete a csr in the cluster
k describe csr <name>
# to see the details of a csr in the cluster

k certificates approve adam
# to approve a csr in the cluster

k get csr adam -o jsonpath='{.status.certificate}' | base64 --decode > adam.crt
# to extract the certificate from the csr and save it to a file named 'adam.crt'
# The certificate is in base64 encoded format, so the command decodes it before saving. 

k get csr <name> -o yaml  > issued-csr.yaml
# to get the full details of the csr in yaml format

k describe csr <name>
# to see the details of a csr in the cluster

echo ".status.certificate" | base64 --decode > adam.crt
# to extract the certificate from the csr and save it to a file named 'adam.crt'
# The certificate is in base64 encoded format, so the command decodes it before saving. 




