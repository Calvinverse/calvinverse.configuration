resource "consul_key_prefix" "consul-kv-service-proxy" {
  token      = var.consul_acl_token

  path_prefix = "config/services/proxy.edge/"

  subkeys = {
    "ui/color"     = var.proxy_ui_color
    "ui/title"     = var.proxy_ui_title
  }

  subkey {
    path  = "statsd/rules"
    value = filebase64("${path.module}/statsd_rules.txt")
  }

}