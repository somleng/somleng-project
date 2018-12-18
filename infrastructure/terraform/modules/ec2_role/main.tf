resource "aws_iam_role" "ec2_instance_role" {
  name = "${var.role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.role_name}"
  role = "${aws_iam_role.ec2_instance_role.name}"
}
