output "delivery_method" {
  value = "smtp"
}

output "smtp_address" {
  value = "email-smtp.us-east-1.amazonaws.com"
}

output "smtp_port" {
  value = "587"
}

output "smtp_username" {
  value = "${aws_iam_access_key.ses_sender.id}"
}

output "smtp_password" {
  value = "${aws_iam_access_key.ses_sender.ses_smtp_password}"
}

output "smtp_authentication_method" {
  value = "login"
}

output "smtp_enable_starttls_auto" {
  value = "1"
}
