output "multi_container_docker_name" {
  value = "${data.aws_elastic_beanstalk_solution_stack.multi_container_docker.name}"
}

output "ruby_name" {
  value = "${data.aws_elastic_beanstalk_solution_stack.ruby.name}"
}
