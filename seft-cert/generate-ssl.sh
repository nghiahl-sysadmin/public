openssl genpkey -algorithm RSA -out key.pem && openssl req -new -key key.pem -out csr.pem -config server.cnf && openssl x509 -req -in csr.pem -signkey key.pem -out cert.pem -days 3650
