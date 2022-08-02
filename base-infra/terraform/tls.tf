terraform {
  required_providers {
    acme = {
      source = "vancluever/acme"
      version = "~> 2.0"
    }
  }
}

provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
  #TODO switch to production URL
  # https://acme-v02.api.letsencrypt.org/directory
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "performance-tests@cloudfoundry.com"
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = "*.cf.${var.domain}"
  subject_alternative_names = [
    "*.cfapps.cf.${var.domain}", 
    "*.login.cf.${var.domain}", 
    "*.uaa.cf.${var.domain}"
    ]

  recursive_nameservers = ["8.8.8.8:53"]

  dns_challenge {
    provider = "route53"
  }
}

output "private_key" {
    value = acme_certificate.certificate.private_key_pem
    sensitive = true
}

output "certificate" {
    value = acme_certificate.certificate.certificate_pem
    sensitive = true
}