# Allow tokens to read and renew the credentials
# The name of the credential to read ('readwrite.vhost.build.trigger') points to the
# role with the same name
path "rabbitmq/creds/readwrite.vhost.build.trigger" {
    capabilities = ["read", "update"]
}
