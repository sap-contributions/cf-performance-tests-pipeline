terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      performance_test_environment = var.test_environment
      managed_by                   = "cf-performance-tests-pipeline"
    }
  }
}
provider "tls" {}
