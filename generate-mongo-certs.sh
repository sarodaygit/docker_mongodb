#!/bin/bash
set -e

CERT_DIR="./certs"
mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

# Create CA Key and Certificate
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -days 365 -out ca.pem -config ../openssl.cnf

# Create MongoDB Server Key and CSR
openssl genrsa -out mongodb.key 4096
openssl req -new -key mongodb.key -out mongodb.csr -config ../openssl.cnf

# Sign the CSR with CA
openssl x509 -req -in mongodb.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out mongodb.crt -days 365 -sha256 -extensions v3_req -extfile ../openssl.cnf

# Combine cert and key
cat mongodb.crt mongodb.key > mongodb.pem

echo "✅ TLS certificates generated in $CERT_DIR"
