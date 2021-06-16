terraform {
  required_version = "~> 0.15.4"

  required_providers {
    consul = {
      version = "~> 2.12.0"
    }
  }
}

provider "consul" {
  address = "${var.consul_server_hostname}:${var.consul_server_port}"
  datacenter = var.consul_datacenter
}
