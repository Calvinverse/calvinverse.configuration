locals {
  kv_prefix = "config/services/proxy.edge"
}

resource "consul_keys" "proxy-ui-color" {
  token      = var.consul_acl_token

  key {
    path = "${local.kv_prefix}/ui/color"
    value = var.proxy_ui_color
  }
}

resource "consul_keys" "proxy-ui-title" {
  token      = var.consul_acl_token

  key {
    path = "${local.kv_prefix}/ui/title"
    value = var.proxy_ui_title
  }
}

resource "consul_keys" "proxy-statsd-rules" {
  token      = var.consul_acl_token

  key {
    path = "${local.kv_prefix}/statsd/rules"
    value = filebase64("${path.module}/statsd_rules.txt")
  }
}
