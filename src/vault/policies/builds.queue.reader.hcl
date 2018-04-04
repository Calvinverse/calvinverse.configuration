# Allow tokens to read and renew the credentials
path "rabbitmq/creds/builds.queue.reader" {
    capabilities = ["read", "update"]
}
