resource "aws_ecs_cluster" "somleng" {
  name = "somleng"
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}
