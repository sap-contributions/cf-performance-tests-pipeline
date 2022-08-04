output "bbl_aws_creds" {
  sensitive = true
  value = {
    aws_access_key_id     = aws_iam_access_key.bbl.id
    aws_secret_access_key = aws_iam_access_key.bbl.secret
  }
}

output "cloud_controller_aws_creds" {
  sensitive = true
  value = {
    aws_access_key_id     = aws_iam_access_key.cloud_controller.id
    aws_secret_access_key = aws_iam_access_key.cloud_controller.secret
  }
}

output "packages_bucket_name" {
  value = aws_s3_bucket.cc-blobstore-packages.name
}
output "buildpacks_bucket_name" {
  value = aws_s3_bucket.cc-blobstore-buildpacks.name
}
output "droplets_bucket_name" {
  value = aws_s3_bucket.cc-blobstore-droplets.name
}
output "resources_bucket_name" {
  value = aws_s3_bucket.cc-blobstore-resources.name
}

output "cert_pem" {
  value = tls_self_signed_cert.sys_domain.cert_pem
}

output "private_key" {
  value     = tls_private_key.sys_domain.private_key_pem
  sensitive = true
}