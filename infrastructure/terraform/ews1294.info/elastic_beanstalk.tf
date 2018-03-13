resource "aws_elastic_beanstalk_application" "scfm" {
  name = "scfm"
}

resource "aws_elastic_beanstalk_configuration_template" "scfm" {
  name                = "scfm"
  application         = "${aws_elastic_beanstalk_application.scfm.name}"
  solution_stack_name = "64bit Amazon Linux 2017.09 v2.7.1 running Ruby 2.5 (Puma)"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${aws_vpc.pin.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name = "Subnets"
    value = "${aws_subnet.private-1a.id},${aws_subnet.private-1b.id},${aws_subnet.private-1c.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBSubnets"
    value = "${aws_subnet.public-1a.id},${aws_subnet.public-1b.id},${aws_subnet.public-1c.id}"
  }

  # http://amzn.to/2FR9RTu
  # Configure your environment's architecture and service role.
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "ServiceRole"
    value = "${data.aws_iam_role.eb_service_role.name}"
  }

  # http://amzn.to/2FjIpj6
  # Configure your environment's EC2 instances.
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = "${data.aws_iam_role.eb_ec2_instance_role.name}"
  }

  # http://amzn.to/2thpK2U
  # Configure rolling deployments for your application code
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "DeploymentPolicy"
    value = "Immutable"
  }

  # http://amzn.to/2oMEP78
  # Configure rolling updates your environment's Auto Scaling group.
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name = "RollingUpdateEnabled"
    value = "true"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name = "RollingUpdateType"
    value = "Immutable"
  }

  # http://amzn.to/2FbOMlh
  # Configure enhanced health reporting for your environment.
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name = "SystemType"
    value = "enhanced"
  }

  # http://amzn.to/2tcRsOe
  # Configure managed platform updates for your environment.
  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name = "ManagedActionsEnabled"
    value = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name = "PreferredStartTime"
    value = "Sun:19:00"
  }

  # http://amzn.to/2tccGLY
  # Configure managed platform updates for your environment.
  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name = "InstanceRefreshEnabled"
    value = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name = "UpdateLevel"
    value = "minor"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "AWS_REGION"
    value = "${var.aws_region}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RACK_ENV"
    value = "production"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RAILS_ENV"
    value = "production"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "DB_POOL"
    value = "48"
  }
}

# resource "aws_elastic_beanstalk_environment" "scfm_web" {
#   name                = "scfm-web"
#   application         = "${aws_elastic_beanstalk_application.scfm.name}"
#   tier                = "WebServer"
#   template_name = "${aws_elastic_beanstalk_configuration_template.scfm.name}"
#
#   setting {
#     namespace = "aws:autoscaling:launchconfiguration"
#     name = "InstanceType"
#     value = "t2.micro"
#   }
# end
