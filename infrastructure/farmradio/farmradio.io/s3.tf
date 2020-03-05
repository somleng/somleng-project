resource "aws_s3_bucket" "naked_redirect" {
  bucket = "farmradio.io"
  acl    = "private"

  website {
    redirect_all_requests_to = "https://farmradio.org"
  }
}

resource "aws_s3_bucket" "www_redirect" {
  bucket = "www.farmradio.io"
  acl    = "private"

  website {
    redirect_all_requests_to = "https://farmradio.org"
  }
}