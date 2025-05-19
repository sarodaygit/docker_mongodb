
# MongoDB TLS + Non-TLS Setup Using Docker

This guide walks you through setting up **two MongoDB instances** via Docker Compose:

- ✅ `mongodb-prod` with TLS enabled on port `27019`
- ✅ `mongodb-dev` without TLS on port `27018`

---

## 📁 Project Structure

```bash
mongodb_tls_ready/
├── certs/                       # TLS certificates (generated locally)
│   ├── ca.pem
│   ├── mongodb.key
│   ├── mongodb.pem
├── docker-compose.prod.yml     # MongoDB with TLS
├── docker-compose.dev.yml      # MongoDB without TLS
├── openssl.cnf                 # Config for generating certs
├── generate-mongo-certs.sh     # Script to generate TLS certs
├── .gitignore
└── README.md
```

---

## ✅ 1. Generate TLS Certificates

Run the following to generate certs inside the `certs/` folder:

```bash
bash generate-mongo-certs.sh
```

Ensure `openssl.cnf` has:

```ini
[ v3_req ]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[ alt_names ]
IP.1 = 192.168.1.7
```

---

## 🚀 2. Start MongoDB Containers

### TLS-enabled (prod) MongoDB

```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Non-TLS (dev) MongoDB

```bash
docker-compose -f docker-compose.dev.yml up -d
```

> ⚠️ Avoid using `--remove-orphans` if both containers must co-exist.

---

## 🔗 3. Connection Strings

### For `mongodb-prod` (TLS)

**From external host or tools like Studio 3T:**

```text
mongodb://produser:prodpass@192.168.1.7:27019/?tls=true&tlsCAFile=<path-to>/ca.pem&tlsAllowInvalidHostnames=true&authSource=admin
```

> Replace `<path-to>` with local path to `ca.pem` on your **client**.

### For `mongodb-dev` (No TLS)

```text
mongodb://devuser:devpass@192.168.1.7:27018/?authSource=admin
```

---

## 💻 4. Copy Certificate to Client (Windows)

1. Copy `ca.pem` from your server to Windows client.
2. Place it in a known directory like: `C:\Users\yourname\certs\ca.pem`
3. Use that path in Studio 3T or Mongo URI connection.

---

## 🛑 5. Security Best Practices

- Never commit certs or `.key` files to GitHub.
- Use `.gitignore` to exclude `certs/` folder.
- Use strong passwords for users.

---

## ✅ Testing TLS

```bash
openssl s_client -connect 192.168.1.7:27019 -CAfile certs/ca.pem
```

Look for `Verify return code: 0 (ok)` and matching `CN = 192.168.1.7`

---

Happy developing!

---

## 🧪 Loading Sample Data into MongoDB

You can load sample data into both the **prod** (TLS-enabled) and **dev** (non-TLS) MongoDB containers using the following methods.

### 📥 Option 1: Load from MongoDB Atlas Archive (Recommended for Prod)

Download and restore using:
curl https://atlas-education.s3.amazonaws.com/sampledata.archive -o sampledata.archive
https://github.com/ozlerhakan/mongodb-json-files
```bash
curl https://atlas-education.s3.amazonaws.com/sampledata.archive -o sampledata.archive
docker cp sampledata.archive mongodb-prod:/sampledata.archive

# Inside the container:
docker exec -it mongodb-prod mongorestore --archive=/sampledata.archive --nsInclude=sample_mflix.*
```

This restores the `sample_mflix` dataset (e.g., movies, comments, users).

---

### 📥 Option 2: Load from GitHub JSON Files (Works for Dev)

Clone the repo:

```bash
git clone https://github.com/ozlerhakan/mongodb-json-files
cd mongodb-json-files
```

Import one or more JSON files (e.g., `students.json`) into dev MongoDB:

```bash
docker cp students.json mongodb-dev:/students.json
docker exec -it mongodb-dev mongoimport --db school --collection students --file /students.json --jsonArray --username devuser --password devpass --authenticationDatabase admin
```

> ℹ️ Adjust the database/collection names as needed based on the files in the repo.

mongorestore   --host localhost   --port 27018   --username devuser   --password devpass   --authenticationDatabase admin --archive=sampledata.archive

---
