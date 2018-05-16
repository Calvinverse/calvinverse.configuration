# Allow tokens to read and renew the credentials
path "rabbitmq/creds/write.vhost.logs.syslog" {
    capabilities = ["read", "update"]
}
