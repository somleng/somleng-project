data "aws_subnet" "this" {
  id = aws_network_interface.this.subnet_id
}

resource "aws_autoscaling_group" "this" {
  name = "nat-instance"

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  vpc_zone_identifier       = [data.aws_subnet.this.id]
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  termination_policies = ["OldestInstance"]

  tag {
    key                 = "Name"
    value               = var.identifier
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
    triggers = ["tag"]
  }

  instance_maintenance_policy {
    min_healthy_percentage = 0
    max_healthy_percentage = 100
  }

  lifecycle {
    create_before_destroy = true
  }
}
