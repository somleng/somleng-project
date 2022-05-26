resource "aws_s3_bucket" "www_somleng_com" {
  bucket = "www.somleng.com"
}

resource "aws_s3_bucket" "somleng_com" {
  bucket = "somleng.com"
}

resource "aws_s3_bucket_website_configuration" "somleng_com" {
  bucket = aws_s3_bucket.somleng_com.bucket

  redirect_all_requests_to {
    host_name = "www.somleng.org"
    protocol = "https"
  }
}

resource "aws_s3_bucket_website_configuration" "www_somleng_com" {
  bucket = aws_s3_bucket.www_somleng_com.bucket

  redirect_all_requests_to {
    host_name = "www.somleng.org"
    protocol = "https"
  }
}
