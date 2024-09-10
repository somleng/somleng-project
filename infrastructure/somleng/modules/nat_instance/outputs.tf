output "health_checker_image" {
  value = local.health_checker_image
}

output "public_ip" {
  value = aws_eip.this.public_ip
}

output "network_interface" {
  value = aws_network_interface.this
}
