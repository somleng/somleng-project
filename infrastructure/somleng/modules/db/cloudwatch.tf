resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/rds/cluster/${local.database_identifier}/postgresql"
  retention_in_days = 7
}
