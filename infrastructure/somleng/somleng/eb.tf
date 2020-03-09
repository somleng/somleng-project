data "aws_elastic_beanstalk_solution_stack" "multi_container_docker" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux (.*) running Multi-container Docker (.*)$"
}

data "aws_elastic_beanstalk_hosted_zone" "current" {}