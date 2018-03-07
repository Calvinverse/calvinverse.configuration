# Allow tokens to read and renew the credentials
path "rabbitmq/creds/logs.syslog.writer" {
    capabilities = ["read", "update"]
}
