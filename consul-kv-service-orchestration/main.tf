locals {
  kv_prefix = "config/services/orchestration"
}

resource "consul_keys" "orchestration_region" {
  token      = var.consul_acl_token

  key {
    path = "${local.kv_prefix}/region"
    value = var.orchestration_region
  }
}

resource "consul_keys" "orchestration_bootstrap" {
  token      = var.consul_acl_token

  key {
    path = "${local.kv_prefix}/bootstrap"
    value = var.orchestration_bootstrap
  }
}

resource "consul_keys" "orchestration_secrets_role" {
  token      = var.consul_acl_token

  key {
    path = "${local.kv_prefix}/secrets/role"
    value = var.orchestration_secrets_role
  }
}

resource "consul_keys" "orchestration_secrets_enabled" {
  token      = var.consul_acl_token

  key {
    path = "${local.kv_prefix}/secrets/enabled"
    value = var.orchestration_secrets_enabled
  }
}

resource "consul_keys" "orchestration_secrets_tls_skip" {
  token      = var.consul_acl_token

  key {
    path = "${local.kv_prefix}/secrets/tls/skip"
    value = var.orchestration_secrets_tls_skip
  }
}

resource "consul_keys" "orchestration_tls_http" {
  token      = var.consul_acl_token

  key {
    path = "${local.kv_prefix}/tls/http"
    value = var.orchestration_tls_http
  }
}

resource "consul_keys" "orchestration_tls_rpc" {
  token      = var.consul_acl_token

  key {
    path = "${local.kv_prefix}/tls/rpc"
    value = var.orchestration_tls_rpc
  }
}

resource "consul_keys" "orchestration_tls_verify" {
  token      = var.consul_acl_token

  key {
    path = "${local.kv_prefix}/tls/verify"
    value = var.orchestration_tls_verify
  }
}
