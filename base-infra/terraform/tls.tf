resource "tls_private_key" "sys_domain" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "sys_domain" {
  private_key_pem = tls_private_key.sys_domain.private_key_pem

  validity_period_hours = 4032

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["*.${var.system_domain}", "ssh.${var.system_domain}", "bosh.${var.system_domain}", "tcp.${var.system_domain}", "*.iso-seg.${var.system_domain}"]

  subject {
    common_name = var.system_domain
  }
}
