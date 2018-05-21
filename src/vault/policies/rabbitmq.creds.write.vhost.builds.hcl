# Allow tokens to read and renew the credentials
path "rabbitmq/creds/write.vhost.builds" {
    capabilities = ["read", "update"]
}
