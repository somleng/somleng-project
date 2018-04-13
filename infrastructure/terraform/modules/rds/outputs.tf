output "security_group" {
  description = "The ID of the security group"
  value       = "${aws_security_group.db.id}"
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = "${module.db.this_db_instance_endpoint}"
}

output "db_username" {
  description = "The master username for the database"
  value       = "${module.db.this_db_instance_username}"
}

output "db_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = "${module.db.this_db_instance_password}"
}

output "db_instance_name" {
  description = "The database name"
  value       = "${module.db.this_db_instance_name}"
}
