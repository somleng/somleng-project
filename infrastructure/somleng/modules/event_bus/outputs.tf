output "this" {
  value = data.aws_cloudwatch_event_bus.this
}

output "target_role" {
  value = aws_iam_role.event_bus_target
}
