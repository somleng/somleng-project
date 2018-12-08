output "public_ip" {
  value = "${aws_eip.eip.public_ip}"
}

output "cname" {
  value = "${module.eb_env.cname}"
}

output "security_group_id" {
  value = "${aws_security_group.sg.id}"
}
