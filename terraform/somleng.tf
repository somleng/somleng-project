variable "aws_shared_credentials_file" {}
variable "aws_region" {
  default = "ap-southeast-1"
}

provider "aws" {
  region = "${var.aws_region}"
  shared_credentials_file = "${var.aws_shared_credentials_file}"
  profile                 = "${terraform.workspace}-terraform"
}

resource "aws_vpc" "somleng" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "somleng"
  }
}

resource "aws_subnet" "public-1a" {
  vpc_id            = "${aws_vpc.somleng.id}"
  availability_zone = "ap-southeast-1a"
  cidr_block        = "${cidrsubnet(aws_vpc.somleng.cidr_block, 8, 0)}"

  tags {
    Name = "public-1a"
  }
}

resource "aws_subnet" "public-1b" {
  vpc_id            = "${aws_vpc.somleng.id}"
  availability_zone = "ap-southeast-1b"
  cidr_block        = "${cidrsubnet(aws_vpc.somleng.cidr_block, 8, 1)}"

  tags {
    Name = "public-1b"
  }
}

resource "aws_subnet" "public-1c" {
  vpc_id            = "${aws_vpc.somleng.id}"
  availability_zone = "ap-southeast-1c"
  cidr_block        = "${cidrsubnet(aws_vpc.somleng.cidr_block, 8, 4)}"

  tags {
    Name = "public-1c"
  }
}

resource "aws_subnet" "private-1a" {
  vpc_id            = "${aws_vpc.somleng.id}"
  availability_zone = "ap-southeast-1a"
  cidr_block        = "${cidrsubnet(aws_vpc.somleng.cidr_block, 8, 2)}"

  tags {
    Name = "private-1a"
  }
}

resource "aws_subnet" "private-1b" {
  vpc_id            = "${aws_vpc.somleng.id}"
  availability_zone = "ap-southeast-1b"
  cidr_block        = "${cidrsubnet(aws_vpc.somleng.cidr_block, 8, 3)}"

  tags {
    Name = "private-1b"
  }
}

resource "aws_subnet" "private-1c" {
  vpc_id            = "${aws_vpc.somleng.id}"
  availability_zone = "ap-southeast-1c"
  cidr_block        = "${cidrsubnet(aws_vpc.somleng.cidr_block, 8, 5)}"

  tags {
    Name = "private-1c"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.somleng.id}"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.somleng.id}"

  tags {
    Name = "public-subnets"
  }
}

resource "aws_route" "igw" {
  route_table_id            = "${aws_route_table.public_route_table.id}"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = "${aws_internet_gateway.gw.id}"
}

resource "aws_route_table_association" "public-1a" {
  subnet_id      = "${aws_subnet.public-1a.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "public-1b" {
  subnet_id      = "${aws_subnet.public-1b.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "public-1c" {
  subnet_id      = "${aws_subnet.public-1c.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}
#
# resource "aws_eip" "nat_gateway_eip" {
#   vpc      = true
#   depends_on = ["aws_internet_gateway.gw"]
# }
#
# resource "aws_nat_gateway" "nat_gateway" {
#   allocation_id = "${aws_eip.nat_gateway_eip.id}"
#   subnet_id = "${aws_subnet.public-1a.id}"
#   depends_on = ["aws_internet_gateway.gw"]
#
#   tags {
#     Name = "${terraform.workspace}"
#   }
# }
#
# resource "aws_route_table" "private_route_table" {
#   vpc_id = "${aws_vpc.bongloy.id}"
#
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = "${aws_nat_gateway.nat_gateway.id}"
#   }
#
#   tags {
#     Name = "${terraform.workspace}-private"
#   }
# }
#
# resource "aws_route_table_association" "live-private-1a" {
#   subnet_id      = "${aws_subnet.live-private-1a.id}"
#   route_table_id = "${aws_route_table.private_route_table.id}"
# }
# resource "aws_route_table_association" "live-private-1b" {
#   subnet_id      = "${aws_subnet.live-private-1b.id}"
#   route_table_id = "${aws_route_table.private_route_table.id}"
# }
# resource "aws_route_table_association" "live-private-1c" {
#   subnet_id      = "${aws_subnet.live-private-1c.id}"
#   route_table_id = "${aws_route_table.private_route_table.id}"
# }
#
# resource "aws_security_group" "rds" {
#   name        = "${terraform.workspace}-rds"
#   vpc_id      = "${aws_vpc.bongloy.id}"
#
#   ingress {
#     from_port   = 5432
#     to_port     = 5432
#     protocol    = "TCP"
#     self        = true
#   }
# }
#
# resource "aws_db_subnet_group" "bongloy" {
#   name       = "bongloy-${terraform.workspace}"
#   subnet_ids = ["${aws_subnet.live-private-1a.id}", "${aws_subnet.live-private-1b.id}", "${aws_subnet.live-private-1c.id}"]
#
#   tags {
#     Name = "bongloy-${terraform.workspace}"
#   }
# }
#
# resource "aws_db_instance" "bongloy" {
#   identifier           = "bongloy-${terraform.workspace}"
#   name                 = "bongloy_${terraform.workspace}"
#   final_snapshot_identifier = "bongloy-${terraform.workspace}"
#   allocated_storage    = 5
#   engine               = "postgres"
#   instance_class       = "${var.aws_rds_instance_types[terraform.workspace]}"
#   storage_type         = "gp2"
#   username             = "bongloy"
#   password             = "${data.aws_kms_secret.db.master_password}"
#   multi_az             = true
#   backup_retention_period = 30
#   storage_encrypted      = "${terraform.workspace == "production" ? true : false}"
#   vpc_security_group_ids = ["${aws_security_group.rds.id}"]
#   db_subnet_group_name = "${aws_db_subnet_group.bongloy.name}"
# }
#
# resource "aws_elastic_beanstalk_application" "bongloy" {
#   name = "bongloy-${terraform.workspace}"
# }
#
# resource "aws_elastic_beanstalk_configuration_template" "bongloy" {
#   name                = "tf-test-template-config"
#   application         = "${aws_elastic_beanstalk_application.bongloy.name}"
#   solution_stack_name = "64bit amazon linux 2017.09 v2.6.5 running ruby 2.4 (puma)"
#
#   setting {
#     namespace = "aws:ec2:vpc"
#     name      = "VPCId"
#     value     = "${aws_vpc.bongloy.id}"
#   }
#
#   setting {
#     namespace = "aws:ec2:vpc"
#     name = "Subnets"
#     value = "${aws_subnet.live-private-1a.id},${aws_subnet.live-private-1b.id},${aws_subnet.live-private-1c.id}"
#   }
#
#   setting {
#     namespace = "aws:ec2:vpc"
#     name = "ELBSubnets"
#     value = "${aws_subnet.public-1a.id},${aws_subnet.public-1b.id},${aws_subnet.public-1c.id}"
#   }
#
#   setting {
#     namespace = "aws:elasticbeanstalk:application:environment"
#     name = "DATABASE_URL"
#     value = "${aws_db_instance.bongloy.endpoint}"
#
#    }
#
#    #security groups
#
#    #AWS_SQS_QUEUE_NAME = awseb-e-kr6d9a2qcc-stack-AWSEBWorkerQueue-4769O1BH06VY
#    #RACK_ENV = staging
#    #RAILS_SKIP_MIGRATIONS = false
#    #RAILS_ENV = staging
#    #RAILS_SKIP_ASSET_COMPILATION = false
#    #DATABASE_URL = postgres://bongloy:AwUEJnxjtVAUsiJkhDDZU2vg@bongloy-staging.ck9k7ipskgne.us-east-1.rds.amazonaws.com:5432/bongloy_staging
# }
#
# resource "aws_elastic_beanstalk_environment" "bongloy-live-web" {
#   name                = "live-web"
#   application         = "${aws_elastic_beanstalk_application.bongloy.name}"
#   tier                = "WebServer"
#   template_name = "${aws_elastic_beanstalk_configuration_template.bongloy.name}"
# }
#
# #resource "aws_elastic_beanstalk_environment" "bongloy-live-worker" {
#   #name                = "live-worker"
#   #application         = "${aws_elastic_beanstalk_application.bongloy.name}"
#   #tier                = "Worker"
#   #template_name = "${aws_elastic_beanstalk_configuration_template.bongloy.name}"
# #}
