locals {
  freeswitch_app_identifier = "somleng-freeswitch"
}

resource "aws_ssm_parameter" "somleng_freeswitch_mod_rayo_password" {
  name  = "freeswitch.mod_rayo.password"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "freeswitch_mod_rayo_shared_secret" {
  name  = "freeswitch.mod_rayo.shared_secret"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_eip" "freeswitch" {
  vpc = true

  tags = {
    Name = "FreeSWITCH Public IP"
  }
}

resource "aws_security_group" "freeswitch" {
  name        = local.freeswitch_app_identifier
  description = "Whitelisted voice providers"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "FreeSWITCH Security Group for VoIP providers"
  }
}

resource "aws_security_group_rule" "orange_sierra_leone" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["197.215.105.30/32"]
  description = "Orange Sierra Leone"

  security_group_id = aws_security_group.freeswitch.id
}

resource "aws_security_group_rule" "hormuud_somalia" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["41.78.73.242/32"]
  description = "Hormuud Somalia"

  security_group_id = aws_security_group.freeswitch.id
}

resource "aws_security_group_rule" "smart_cambodia" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["27.109.112.140/32"]
  description = "Smart Cambodia"

  security_group_id = aws_security_group.freeswitch.id
}

resource "aws_security_group_rule" "cellcard_cambodia" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["103.193.204.26/32"]
  description = "Cellcard Cambodia"

  security_group_id = aws_security_group.freeswitch.id
}

resource "aws_security_group_rule" "metfone_cambodia" {
  type        = "ingress"
  from_port   = 5060
  to_port     = 5060
  protocol    = "udp"
  cidr_blocks = ["175.100.93.13/32"]
  description = "Metfone Cambodia"

  security_group_id = aws_security_group.freeswitch.id
}

resource "aws_eip_association" "eip" {
  instance_id   = aws_elastic_beanstalk_environment.freeswitch_webserver.instances.0
  allocation_id = aws_eip.freeswitch.id
}

resource "aws_elastic_beanstalk_application" "freeswitch" {
  name = local.freeswitch_app_identifier

  appversion_lifecycle {
    service_role          = aws_iam_role.eb_service_role.arn
    max_count             = 50
    delete_source_from_s3 = true
  }
}

resource "aws_iam_role" "freeswitch" {
  name = local.freeswitch_app_identifier

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

resource "aws_iam_instance_profile" "freeswitch" {
  name = aws_iam_role.freeswitch.name
  role = aws_iam_role.freeswitch.name
}

resource "aws_iam_role_policy_attachment" "freeswitch_web_tier" {
  role       = aws_iam_role.freeswitch.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "freeswitch_ssm" {
  role       = aws_iam_role.freeswitch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "freeswitch_multicontainer_docker" {
  role = aws_iam_role.freeswitch.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "freeswitch_polly" {
  role = aws_iam_role.freeswitch.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPollyFullAccess"
}

resource "aws_autoscaling_lifecycle_hook" "terminate_instance" {
  name                   = "freeswitch-terminate-instance-hook"
  autoscaling_group_name = aws_elastic_beanstalk_environment.freeswitch_webserver.autoscaling_groups.0
  default_result         = "CONTINUE"
  heartbeat_timeout      = 120
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
}

resource "aws_cloudwatch_event_rule" "terminate_instance" {
  name        = "${local.freeswitch_app_identifier}-associate-eip"
  description = "Associate Elastic IP"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.autoscaling"
  ],
  "detail-type": [
    "${local.event_detail_type}"
  ],
  "detail": {
    "AutoScalingGroupName": [
      "${aws_elastic_beanstalk_environment.freeswitch_webserver.autoscaling_groups.0}"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = aws_cloudwatch_event_rule.terminate_instance.name
  arn  = aws_lambda_function.associate_eip.arn
}

resource "aws_elastic_beanstalk_environment" "freeswitch_webserver" {
  # General Settings

  name                = "${local.freeswitch_app_identifier}-webserver"
  application         = aws_elastic_beanstalk_application.freeswitch.name
  tier                = "WebServer"
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.multi_container_docker.name

  tags = {
    eip_allocation_id = aws_eip.freeswitch.id
  }

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
    value     = join(",", module.vpc.public_subnets)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", module.vpc.intra_subnets)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = true
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
    name      = "SecurityGroups"
    value     = aws_security_group.freeswitch.id
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.2xlarge"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.freeswitch.name
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
    value     = "1"
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
    value     = "5222"
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
  # DRb Listener
  setting {
    namespace = "aws:elbv2:listener:5222"
    name      = "ListenerEnabled"
    value     = "true"
  }
  setting {
    namespace = "aws:elbv2:listener:5222"
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
    name      = "FS_EXTERNAL_IP"
    value     = aws_eip.freeswitch.public_ip
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FS_MOD_RAYO_PORT"
    value     = "5222"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FS_MOD_RAYO_DOMAIN_NAME"
    value     = "rayo.somleng.org"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FS_MOD_RAYO_USER"
    value     = "rayo"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FS_MOD_RAYO_PASSWORD"
    value     = aws_ssm_parameter.somleng_freeswitch_mod_rayo_password.value
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FS_MOD_RAYO_SHARED_SECRET"
    value     = aws_ssm_parameter.somleng_freeswitch_mod_rayo_password.value
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FS_MOD_JSON_CDR_URL"
    value     = "https://twilreapi.somleng.org/api/internal/call_data_records"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FS_MOD_JSON_CDR_CRED"
    value     = "admin:${aws_ssm_parameter.twilreapi_internal_api_password.value}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FS_CORE_LOGLEVEL"
    value     = "notice"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FS_CORE_MAX_SESSIONS"
    value     = "1000"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FS_CORE_SESSIONS_PER_SECOND"
    value     = "1000"
  }
}

resource "aws_route53_record" "somleng_freeswitch" {
  zone_id = data.terraform_remote_state.core.outputs.somleng_internal_zone.id
  name    = "somleng-freeswitch"
  type    = "A"

  alias {
    name                   = aws_elastic_beanstalk_environment.freeswitch_webserver.cname
    zone_id                = data.aws_elastic_beanstalk_hosted_zone.current.id
    evaluate_target_health = true
  }
}