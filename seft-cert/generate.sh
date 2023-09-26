# Generate CA Key
openssl genpkey -algorithm RSA -out ca-key.pem

# Create CA Certificate (Self-signed)
openssl req -new -x509 -key ca-key.pem -out ca-cert.pem -config root-ca.cnf -days 3650

# Generate Key for the server
openssl genpkey -algorithm RSA -out server-key.pem

# Create CSR (Certificate Signing Request) for the server
openssl req -new -key server-key.pem -out server-csr.pem -config server.cnf

# Sign CSR with CA Key to create a certificate for the server
openssl x509 -req -in server-csr.pem -CA ca-cert.pem -CAkey ca-key.pem -out server-cert.pem -days 365

# Check the web server's certificate
echo "-------------------------------------------"
echo "Certificate End Date for Server Certificate"
openssl x509 -noout -enddate -in server-cert.pem | cut -d "=" -f 2
echo "---------------------------------------"
echo "Certificate End Date for CA Certificate"
openssl x509 -noout -enddate -in ca-cert.pem | cut -d "=" -f 2
