# Role to be used by other region event buses to put events to the default event bus in this region.

locals {
  event_bus_target_role_name = "${var.alias}-default-event-bus-target"
}

data "aws_cloudwatch_event_bus" "default" {
  name = "default"
}

data "aws_iam_policy_document" "event_bus_target_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "event_bus_target" {
  name               = local.event_bus_target_role_name
  assume_role_policy = data.aws_iam_policy_document.event_bus_target_assume_role_policy.json
}

data "aws_iam_policy_document" "invoke_event_bus" {
  statement {
    effect    = "Allow"
    actions   = ["events:PutEvents"]
    resources = [data.aws_cloudwatch_event_bus.default.arn]
  }
}

resource "aws_iam_policy" "invoke_event_bus" {
  name   = local.event_bus_target_role_name
  policy = data.aws_iam_policy_document.invoke_event_bus.json
}

resource "aws_iam_role_policy_attachment" "invoke_event_bus" {
  role       = aws_iam_role.event_bus_target.name
  policy_arn = aws_iam_policy.invoke_event_bus.arn
}
