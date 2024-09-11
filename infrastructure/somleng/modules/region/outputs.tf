output "vpc" {
  value = module.vpc
}

output "public_load_balancer" {
  value = var.create_public_load_balancer ? module.public_load_balancer[0] : null
}

output "internal_load_balancer" {
  value = var.create_internal_load_balancer ? module.internal_load_balancer[0] : null
}

output "logs_bucket" {
  value = aws_s3_bucket.logs
}

output "alias" {
  value = var.alias
}

output "aws_region" {
  value = data.aws_region.this.name
}

output "event_bus" {
  value = module.event_bus
}

output "nat_instance" {
  value = local.nat_instance
}
