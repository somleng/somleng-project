data "aws_cloudwatch_event_bus" "this" {
  name = var.event_bus_name
}
