output "access_key_id" {
  value = "${aws_iam_access_key.ses_sender.id}"
}

output "smtp_password" {
  value = "${aws_iam_access_key.ses_sender.ses_smtp_password}"
}

output "smtp_server_name" {
  value = "email-smtp.us-east-1.amazonaws.com"
}
