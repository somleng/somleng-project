resource "aws_kms_key" "master" {
  description         = "Master Key"
  enable_key_rotation = true

  tags {
    Name = "terraform-master-key"
  }
}

resource "aws_kms_alias" "master" {
  name          = "alias/master"
  target_key_id = "${aws_kms_key.master.key_id}"
}
