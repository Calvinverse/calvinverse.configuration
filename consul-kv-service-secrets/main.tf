locals {
  kv_prefix = "config/services/secrets"
}

resource "consul_keys" "secrets-protocols-http-host" {
  token      = var.consul_acl_token

  key {
    path = "${local.kv_prefix}/protocols/http/host"
    value = var.secrets_protocols_http_hostname
  }
}

resource "consul_keys" "secrets-protocols-http-port" {
  token      = var.consul_acl_token

  key {
    path = "${local.kv_prefix}/protocol/http/port"
    value = var.secrets_protocols_http_port
  }
}

resource "consul_keys" "secrets-statsd-rules" {
  token      = var.consul_acl_token

  key {
    path = "${local.kv_prefix}/metrics/statsd/rules"
    value = filebase64("${path.module}/statsd_rules.txt")
  }
}
