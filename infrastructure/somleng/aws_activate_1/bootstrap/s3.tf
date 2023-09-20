resource "aws_s3_bucket" "infrastructure" {
  bucket = "infrastructure.aws-activate-1.somleng.org"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "infrastructure" {
  bucket = aws_s3_bucket.infrastructure.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "infrastructure" {
  bucket = aws_s3_bucket.infrastructure.id

  versioning_configuration {
    status = "Enabled"
  }
}
