variable "system_domain" {
  type        = string
  description = "Cloud Foundry's system domain"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "env_name" {
  type        = string
  description = "Name of this test environment"
}
