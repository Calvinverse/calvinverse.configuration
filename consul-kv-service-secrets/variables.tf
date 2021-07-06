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
# PROXY
#

variable "secrets_protocols_http_hostname" {
  description = "The Consul service name for the active secrets server."
  default     = "active.secrets"
}

variable "secrets_protocols_http_port" {
  description = "The port of the active secrets server."
  type        = number
  default     = 8200
}