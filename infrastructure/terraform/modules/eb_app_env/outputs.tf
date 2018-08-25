output "web_cname" {
  value = "${module.eb_web.cname}"
}

output "web_id" {
  value = "${module.eb_web.id}"
}

output "worker_queue_url" {
  value = "${module.eb_worker.aws_sqs_queue_url}"
}

output "worker_autoscaling_groups" {
  value = "${module.eb_worker.autoscaling_groups}"
}
