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
# ORCHESTRATION
#

variable "orchestration_region" {
  description = "The region in which the orchestration server is placed."
  type        = string
}

variable "orchestration_bootstrap" {
  description = "The number of orchestration hosts that are expected in the cluster."
  type        = number
  default     = 1
}

variable "orchestration_secrets_role" {
  description = "The vault role used to create tokens for tasks via the provided role. This allows the role to manage what policies are allowed and disallowed for use by tasks."
  type        = string
}

variable "orchestration_secrets_enabled" {
  description = "Boolean flag which indicates if integration with Vault should be enabled."
  type        = string
}

variable "orchestration_secrets_tls_skip" {
  description = "Boolean flag which indicates if tls verification should be skipped for interaction with Vault."
  type        = string
  default     = "true"
}

variable "orchestration_tls_http" {
  description = "Boolean flag which indicates if tls verification should be enabled for HTTP connections."
  type        = string
  default     = "false"
}

variable "orchestration_tls_rpc" {
  description = "Boolean flag which indicates if tls verification should be enabled for RPC connections."
  type        = string
  default     = "false"
}

variable "orchestration_tls_verify" {
  description = "Boolean flag which indicates if tls verification should be enabled for the incoming host."
  type        = string
  default     = "false"
}
