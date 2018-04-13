output "docker_name" {
  value = "${data.aws_elastic_beanstalk_solution_stack.single_docker.name}"
}

output "ruby_name" {
  value = "${data.aws_elastic_beanstalk_solution_stack.ruby.name}"
}
