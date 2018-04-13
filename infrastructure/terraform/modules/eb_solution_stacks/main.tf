data "aws_elastic_beanstalk_solution_stack" "single_docker" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux (.*) running Docker (.*)$"
}

data "aws_elastic_beanstalk_solution_stack" "ruby" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux (.*) running Ruby ${var.major_ruby_version} (.*)$"
}
