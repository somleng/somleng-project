locals {
  somleng_adhearsion_app_identifier = "somleng-adhearsion"
}

resource "aws_elastic_beanstalk_application" "somleng_adhearsion" {
  name = local.somleng_adhearsion_app_identifier

  appversion_lifecycle {
    service_role          = aws_iam_role.eb_service_role.arn
    max_count             = 50
    delete_source_from_s3 = true
  }
}

resource "aws_iam_role" "somleng_adhearsion" {
  name = local.somleng_adhearsion_app_identifier

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "somleng_adhearsion" {
  name = aws_iam_role.somleng_adhearsion.name
  role = aws_iam_role.somleng_adhearsion.name
}

resource "aws_iam_role_policy_attachment" "somleng_adhearsion_web_tier" {
  role       = aws_iam_role.somleng_adhearsion.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "somleng_adhearsion_ssm" {
  role       = aws_iam_role.somleng_adhearsion.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "somleng_adhearsion_ssm_multicontainer_docker" {
  role = aws_iam_role.somleng_adhearsion.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_elastic_beanstalk_environment" "somleng_adhearsion_webserver" {
  # General Settings

  name                = "somleng-adhearsion-webserver"
  application         = aws_elastic_beanstalk_application.somleng_adhearsion.name
  tier                = "WebServer"
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.multi_container_docker.name

  ################### VPC ###################
  # https://amzn.to/2JzNUcK
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = module.vpc.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", module.vpc.private_subnets)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", module.vpc.intra_subnets)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = false
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "internal"
  }

  ################### EC2 Settings ###################
  # http://amzn.to/2FjIpj6
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.xlarge"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.somleng_adhearsion.name
  }

  ################### Auto Scaling Group Settings ###################
  # https://amzn.to/2o7M1uD
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "2"
  }

  ################### Code Deployment Settings ###################
  # http://amzn.to/2thpK2U
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "AllAtOnce"
  }

  ################### Rolling Updates ###################
  # http://amzn.to/2oMEP78
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType"
    value     = "Time"
  }

  ################### Health Reporting ###################
  # http://amzn.to/2FbOMlh
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

  ################### Managed Updates ###################
  # http://amzn.to/2tcRsOe
  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "ManagedActionsEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "PreferredStartTime"
    value     = "Sun:19:00"
  }

  ################### Managed Platform Updates ###################
  # http://amzn.to/2tccGLY
  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name      = "InstanceRefreshEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name      = "UpdateLevel"
    value     = "minor"
  }

  ################### CloudWatch Logs ###################
  # https://amzn.to/2uNOMYb
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "DeleteOnTerminate"
    value     = "false"
  }

  ################### Default Process ###################
  # https://amzn.to/2HcmWaG
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = "9050"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Protocol"
    value     = "TCP"
  }
  ################### EB Environment ###################
  # https://amzn.to/2FR9RTu

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_instance_profile.eb_service.name
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "network"
  }
  ################### Listener ###################
  # https://amzn.to/2GzHQiB
  # Default Listener
  setting {
    namespace = "aws:elbv2:listener:default"
    name      = "ListenerEnabled"
    value     = "false"
  }
  # SSL Listener
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "ListenerEnabled"
    value     = "false"
  }
  # DRb Listener
  setting {
    namespace = "aws:elbv2:listener:9050"
    name      = "ListenerEnabled"
    value     = "true"
  }
  setting {
    namespace = "aws:elbv2:listener:9050"
    name      = "Protocol"
    value     = "TCP"
  }
  ################### ENV Vars ###################
  # https://amzn.to/2Ez6CgW
  # Defaults
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_REGION"
    value     = var.aws_region
  }
  # For AWS CLI https://docs.aws.amazon.com/cli/latest/userguide/cli-environment.html
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_DEFAULT_REGION"
    value     = var.aws_region
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AHN_ENV"
    value     = "production"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AHN_CORE_HOST"
    value     = "somleng-freeswitch.internal.somleng.org"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AHN_CORE_PORT"
    value     = "5222"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AHN_CORE_USERNAME"
    value     = "rayo@rayo.somleng.org"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AHN_CORE_PASSWORD"
    value     = aws_ssm_parameter.somleng_freeswitch_mod_rayo_password.value
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AHN_ADHEARSION_DRB_PORT"
    value     = "9050"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AHN_TWILIO_REST_API_PHONE_CALLS_URL"
    value     = "https://admin:${aws_ssm_parameter.twilreapi_internal_api_password.value}@twilreapi.somleng.org/api/internal/phone_calls"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AHN_TWILIO_REST_API_PHONE_CALL_EVENTS_URL"
    value     = "https://admin:${aws_ssm_parameter.twilreapi_internal_api_password.value}@twilreapi.somleng.org/api/internal/phone_calls/:phone_call_id/phone_call_events"
  }
}

resource "aws_route53_record" "somleng_adhearsion" {
  zone_id = data.terraform_remote_state.core.outputs.somleng_internal_zone.id
  name    = "somleng-adhearsion"
  type    = "A"

  alias {
    name                   = aws_elastic_beanstalk_environment.somleng_adhearsion_webserver.cname
    zone_id                = data.aws_elastic_beanstalk_hosted_zone.current.id
    evaluate_target_health = true
  }
}