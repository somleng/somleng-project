output "id" {
  value = "${aws_elastic_beanstalk_environment.eb_env.id}"
}

output "aws_sqs_queue_url" {
  # Terraform evaluates both branches in a conditional
  # Using a conditional to return aws_elastic_beanstalk_environment.eb_env.queues.0
  # evaluates regardless of the condition
  value = "${element(split(",", join(",", aws_elastic_beanstalk_environment.eb_env.queues)), 0)}"
}

output "cname" {
  value = "${aws_elastic_beanstalk_environment.eb_env.cname}"
}
