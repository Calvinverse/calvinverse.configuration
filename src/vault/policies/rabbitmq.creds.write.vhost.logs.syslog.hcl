# Allow tokens to read and renew the credentials
# The name of the credential to read ('write.vhost.logs.syslog') points to the
# role with the same name
path "rabbitmq/creds/write.vhost.logs.syslog" {
    capabilities = ["read", "update"]
}
