data "aws_elastic_beanstalk_solution_stack" "multi_container_docker" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux (.*) running Multi-container Docker (.*)$"
}

data "aws_elastic_beanstalk_solution_stack" "ruby" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux (.*) running Ruby ${var.major_ruby_version} (.*)$"
}

data "aws_elastic_beanstalk_solution_stack" "latest_ruby" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux (.*) running Ruby (.*)$"
}
