locals {
  kv_prefix = "config/services/consul"
}

resource "consul_keys" "servicediscovery-datacenter" {
  token      = var.consul_acl_token

  key {
    path = "${local.kv_prefix}/datacenter"
    value = var.consul_datacenter
  }
}

resource "consul_keys" "servicediscovery-domain" {
  token      = var.consul_acl_token

  key {
    path = "${local.kv_prefix}/domain"
    value = var.consul_domain
  }
}

resource "consul_keys" "servicediscovery-statsd-rules" {
  token      = var.consul_acl_token

  key {
    path  = "${local.kv_prefix}/statsd/rules"
    value = filebase64("${path.module}/statsd_rules.txt")
  }
}
