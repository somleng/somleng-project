resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "${var.bucket}"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name = "S3 Remote Terraform State Store"
  }
}
