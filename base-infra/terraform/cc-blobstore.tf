resource "aws_s3_bucket" "cc-blobstore-packages" {
  bucket        = "perf-tests-pkgs-${var.test_environment}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "packages" {
  bucket = aws_s3_bucket.cc-blobstore-packages.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "packages" {
  bucket = aws_s3_bucket.cc-blobstore-packages.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket" "cc-blobstore-buildpacks" {
  bucket        = "perf-tests-bldpks-${var.test_environment}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "exbuildpacks" {
  bucket = aws_s3_bucket.cc-blobstore-buildpacks.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "buildpacks" {
  bucket = aws_s3_bucket.cc-blobstore-buildpacks.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket" "cc-blobstore-droplets" {
  bucket        = "perf-tests-drops-${var.test_environment}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "droplets" {
  bucket = aws_s3_bucket.cc-blobstore-droplets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "droplets" {
  bucket = aws_s3_bucket.cc-blobstore-droplets.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket" "cc-blobstore-resources" {
  bucket        = "perf-tests-rsrcs-${var.test_environment}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "resources" {
  bucket = aws_s3_bucket.cc-blobstore-resources.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "resources" {
  bucket = aws_s3_bucket.cc-blobstore-resources.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

