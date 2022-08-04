resource "aws_s3_bucket" "cc-blobstore-packages" {
  bucket = "${var.env_name}-perf-tests-packages"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.cc-blobstore-packages.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket" "cc-blobstore-buildpacks" {
  bucket = "${var.env_name}-perf-tests-buildpacks"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.cc-blobstore-packages.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket" "cc-blobstore-droplets" {
  bucket = "${var.env_name}-perf-tests-dropletss"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.cc-blobstore-packages.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket" "cc-blobstore-resources" {
  bucket = "${var.env_name}-perf-tests-resources"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.cc-blobstore-packages.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

