locals {
  queue_name = "${element(split("/", "${var.queue_url}"), length(split("/", "${var.queue_url}")) - 1)}"
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.env_identifier}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${var.autoscaling_group}"
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.env_identifier}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${var.autoscaling_group}"
}

resource "aws_cloudwatch_metric_alarm" "queue_depth_alarm_high" {
  alarm_name          = "${var.env_identifier}-queue-depth-alarm-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "1"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Average"
  alarm_description   = "Alarm if queue depth grows above threshold"
  alarm_actions       = ["${aws_autoscaling_policy.scale_up.arn}"]

  dimensions {
    QueueName = "${local.queue_name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "queue_depth_alarm_low" {
  alarm_name          = "${var.env_identifier}-queue-depth-alarm-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = "0"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Average"
  alarm_description   = "Alarm if queue depth drops below threshold"
  alarm_actions       = ["${aws_autoscaling_policy.scale_down.arn}"]

  dimensions {
    QueueName = "${local.queue_name}"
  }
}
