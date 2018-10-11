output "smtp_username" {
  value = "${aws_iam_access_key.ses_sender.id}"
}

output "smtp_password" {
  value = "${aws_iam_access_key.ses_sender.ses_smtp_password}"
}
