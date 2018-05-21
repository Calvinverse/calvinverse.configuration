# Allow tokens to read and renew the credentials
path "rabbitmq/creds/read.vhost.builds" {
    capabilities = ["read", "update"]
}
