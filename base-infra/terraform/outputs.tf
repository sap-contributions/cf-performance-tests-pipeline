output "aws_creds" {
  sensitive = true
  value = {
    aws_access_key_id     = aws_iam_access_key.pipeline-user.id
    aws_secret_access_key = aws_iam_access_key.pipeline-user.secret
  }
}

output "cert_pem" {
  value = tls_self_signed_cert.sys_domain.cert_pem
}

output "private_key" {
  value     = tls_private_key.sys_domain.private_key_pem
  sensitive = true
}
