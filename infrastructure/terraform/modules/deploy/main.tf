resource "null_resource" "deploy" {
  triggers {
    eb_env_id = "${var.eb_env_id}"
  }

  provisioner "local-exec" {
    command = "${path.module}/travis_deploy ${var.repo} ${var.branch} --token ${var.travis_token}"
  }
}
