resource "consul_key_prefix" "consul-kv-service-servicediscovery" {
  token      = var.consul_acl_token

  path_prefix = "config/services/consul"

  subkeys = {
    "datacenter"  = var.consul_datacenter
    "domain"      = var.consul_domain
  }

  subkey {
    path  = "statsd/rules"
    value = filebase64("${path.module}/statsd_rules.txt")
  }

}
