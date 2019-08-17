output "samnang_user_arn" {
  value = aws_iam_user.samnang.arn
}

output "dwilkie_user_arn" {
  value = aws_iam_user.dwilkie.arn
}

output "infrastructure_bucket" {
  value = aws_s3_bucket.infrastructure.id
}

