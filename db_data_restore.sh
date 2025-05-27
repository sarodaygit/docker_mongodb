# mongosh "mongodb://produser:prodpass@192.168.1.7:27019/?tls=true&tlsCAFile=certs/ca.pem&tlsAllowInvalidHostnames=true" --authenticationDatabase admin

mongorestore   --host localhost   --port 27018   --username devuser   --password devpass   --authenticationDatabase admin   --archive=sample_data/sampledata.archive --nsInclude=sample_mflix.*
# mongorestore   --host=192.168.1.7   --port=27019   --username=produser   --password=prodpass   --authenticationDatabase=admin   --archive=sample_data/sampledata.archive   --nsInclude=sample_mflix.*   --ssl --sslCAFile=certs/ca.pem
