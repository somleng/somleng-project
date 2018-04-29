resource "aws_iam_group" "ses_sender" {
  name = "ses_sender"
}

resource "aws_iam_policy" "ses_sender" {
  name        = "ses_sender"
  description = "Policy for Sending Emails"
  policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"ses:SendRawEmail\",\"Resource\":\"*\"}]}"
}

resource "aws_iam_group_policy_attachment" "ses_sender" {
  group      = "${aws_iam_group.ses_sender.name}"
  policy_arn = "${aws_iam_policy.ses_sender.arn}"
}

resource "aws_iam_user" "ses_sender" {
  name = "ses_sender"
}

resource "aws_iam_group_membership" "ses_sender" {
  name = "ses_sender"

  users = [
    "${aws_iam_user.ses_sender.name}",
  ]

  group = "${aws_iam_group.ses_sender.name}"
}

resource "aws_iam_access_key" "ses_sender" {
  user = "${aws_iam_user.ses_sender.name}"
}

resource "aws_ses_domain_identity" "domain" {
  domain = "${var.route53_domain_name}"
  provider = "aws.us-east-1"
}

resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = "${var.zone_id}"
  name    = "_amazonses"
  type    = "TXT"
  ttl     = "600"
  records = ["${aws_ses_domain_identity.domain.verification_token}"]
}

resource "aws_ses_domain_identity_verification" "verification" {
  domain = "${aws_ses_domain_identity.domain.id}"
  provider = "aws.us-east-1"
  depends_on = ["aws_route53_record.amazonses_verification_record"]
}
