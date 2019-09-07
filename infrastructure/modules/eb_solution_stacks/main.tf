# https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts.platforms.html

data "aws_elastic_beanstalk_solution_stack" "single_docker" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux (.*) running Docker (.*)$"
}

data "aws_elastic_beanstalk_solution_stack" "multi_container_docker" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux (.*) running Multi-container Docker (.*)$"
}

data "aws_elastic_beanstalk_solution_stack" "ruby" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux (.*) running Ruby ${var.major_ruby_version} \\(Puma\\)$"
}
