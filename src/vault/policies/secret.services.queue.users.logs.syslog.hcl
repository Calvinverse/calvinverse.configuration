# Allow tokens to read and renew the credentials
# The name of the credential to read ('write.vhost.logs.syslog') points to the
# role with the same name
path "secret/services/queue/users/logs/syslog" {
    capabilities = ["read", "update"]
}
