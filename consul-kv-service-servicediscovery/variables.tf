#
# CONSUL CONNECTION INFORMATION
#

variable "consul_acl_token" {
  description = "The ACL token that allows writing to the Consul K-V."
  type        = string
}

variable "consul_datacenter" {
  description = "The name of the consul data center."
  type        = string
}

variable "consul_server_hostname" {
  description = "The hostname of one of the consul servers."
  type        = string
}

variable "consul_server_port" {
  description = "The port of one of the consul servers."
  type        = number
}

#
# CONSUL
#

variable "consul_domain" {
  description = "The Consul domain."
  type        = string
}
