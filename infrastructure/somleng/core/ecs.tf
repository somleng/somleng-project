resource "aws_ecs_cluster" "somleng" {
  name = "somleng"
}

resource "aws_ecs_cluster_capacity_providers" "somleng" {
  cluster_name = aws_ecs_cluster.somleng.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}
