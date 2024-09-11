# https://aws.amazon.com/ec2/instance-types/t4/
data "aws_ssm_parameter" "nat_instance" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_launch_template" "this" {
  name_prefix   = "nat-instance"
  image_id      = data.aws_ssm_parameter.nat_instance.value
  instance_type = "t4g.small"

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.this.id]
  }

  user_data = base64encode(join("\n", [
    "#cloud-config",
    yamlencode({
      # https://cloudinit.readthedocs.io/en/latest/topics/modules.html
      write_files : [
        {
          path : "/opt/nat/setup.sh",
          content : templatefile(
            "${path.module}/templates/setup.sh",
            {
              eni_id            = aws_network_interface.this.id,
              eip_allocation_id = aws_eip.this.id
            }
          ),
          permissions : "0755",
        },
        {
          path : "/opt/nat/snat.sh",
          content : file("${path.module}/templates/snat.sh"),
          permissions : "0755",
        },
        {
          path : "/etc/systemd/system/snat.service",
          content : file("${path.module}/templates/snat.service"),
        },
      ],
      runcmd : [
        ["/opt/nat/setup.sh"]
      ],
    })
  ]))

  lifecycle {
    create_before_destroy = true
  }
}
