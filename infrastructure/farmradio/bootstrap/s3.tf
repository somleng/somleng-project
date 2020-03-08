resource "aws_s3_bucket" "infrastructure" {
  bucket = "infrastructure.farmradio.org"
  acl    = "private"
  region = "eu-west-1"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
}
