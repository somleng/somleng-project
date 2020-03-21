locals {
  twilreapi_major_ruby_version = "2.6"
  twilreapi_app_identifier = "somleng-twilreapi"
  twilreapi_db_url = "postgres://${module.twilreapi_db.this_db_instance_username}:${module.twilreapi_db.this_db_instance_password}@${module.twilreapi_db.this_db_instance_endpoint}/${module.twilreapi_db.this_db_instance_name}"
  outbound_call_drb_uri = "druby://somleng-adhearsion.internal.somleng.org:9050"
}

resource "aws_ssm_parameter" "twilreapi_rails_master_key" {
  name  = "twilreapi.rails.master_key"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "twilreapi_db_master_password" {
  name  = "twilreapi.db.master_password"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "twilreapi_internal_api_password" {
  name  = "twilreapi.rails.internal_api_http_auth_password"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_security_group" "twilreapi_db" {
  name   = "somleng-twilreapi-rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "TCP"
    self      = true
  }

  tags = {
    Name = "Twilreapi RDS Security Group"
  }
}

module "twilreapi_db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "somleng-twilreapi"
  name = "somleng_twilreapi"

  engine                      = "postgres"
  engine_version              = "11.5"
  major_engine_version        = "11"
  instance_class              = "db.t3.small"
  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = true
  apply_immediately           = true
  storage_encrypted           = false
  db_subnet_group_name = module.vpc.database_subnet_group

  allocated_storage = 5

  username = "somleng"
  password = aws_ssm_parameter.twilreapi_db_master_password.value
  port     = 5432

  vpc_security_group_ids = [aws_security_group.twilreapi_db.id]

  skip_final_snapshot       = false
  final_snapshot_identifier = local.twilreapi_app_identifier
  backup_retention_period   = 30
  maintenance_window        = "Sun:19:00-Sun:22:00"
  backup_window             = "22:00-00:00"
  deletion_protection       = true
  multi_az                  = false

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  create_db_parameter_group = false
  subnet_ids                = module.vpc.database_subnets
}

data "aws_elastic_beanstalk_solution_stack" "twilreapi" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux (.*) running Ruby ${local.twilreapi_major_ruby_version} \\(Puma\\)$"
}

resource "aws_elastic_beanstalk_application" "twilreapi" {
  name = local.twilreapi_app_identifier

  appversion_lifecycle {
    service_role          = aws_iam_role.eb_service_role.arn
    max_count             = 50
    delete_source_from_s3 = true
  }
}

resource "aws_iam_role" "twilreapi" {
  name = local.twilreapi_app_identifier

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

resource "aws_iam_policy" "twilreapi" {
  name = local.twilreapi_app_identifier

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "${aws_s3_bucket.cdr.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:GetObject"
      ],
      "Resource": [
        "${aws_s3_bucket.cdr.arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "twilreapi" {
  name = aws_iam_role.twilreapi.name
  role = aws_iam_role.twilreapi.name
}

resource "aws_iam_role_policy_attachment" "twilreapi" {
  role       = aws_iam_role.twilreapi.name
  policy_arn = aws_iam_policy.twilreapi.arn
}

resource "aws_iam_role_policy_attachment" "twilreapi_web_tier" {
  role       = aws_iam_role.twilreapi.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "twilreapi_worker_tier" {
  role       = aws_iam_role.twilreapi.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "twilreapi_sqs" {
  role       = aws_iam_role.twilreapi.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "twilreapi_ssm" {
  role       = aws_iam_role.twilreapi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_s3_bucket" "cdr" {
  bucket = "cdr.somleng.org"
  acl    = "private"
  region = var.aws_region
}

resource "aws_elastic_beanstalk_environment" "twilreapi_caller_worker" {
  # General Settings

  name                = "${local.twilreapi_app_identifier}-caller-worker"
  application         = aws_elastic_beanstalk_application.twilreapi.name
  tier                = "Worker"
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.twilreapi.name

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
    name      = "AssociatePublicIpAddress"
    value     = "false"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "public"
  }

  ################### EC2 Settings ###################
  # http://amzn.to/2FjIpj6
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.twilreapi_db.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.micro"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.twilreapi.name
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
    value     = "4"
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
    value     = "80"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Protocol"
    value     = "HTTP"
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
  # Rails Specific
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RAILS_SKIP_ASSET_COMPILATION"
    value     = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RAILS_ENV"
    value     = "production"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RACK_ENV"
    value     = "production"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE_URL"
    value     = local.twilreapi_db_url
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RAILS_MASTER_KEY"
    value     = aws_ssm_parameter.twilreapi_rails_master_key.value
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_POOL"
    value     = "32"
  }
  # Application Specific
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "UPLOADS_BUCKET"
    value     = aws_s3_bucket.cdr.id
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PROCESS_ACTIVE_ELASTIC_JOBS"
    value     = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DEFAULT_URL_HOST"
    value     = "twilreapi.somleng.org"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DEFAULT_QUEUE_URL"
    value     = "`{\"Ref\" : \"AWSEBWorkerQueue\"}`"
  }
  # Twilreapi Specific
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "OUTBOUND_CALL_DRB_URI"
    value     = "druby://somleng-adhearsion.internal.somleng.org:9050"
  }
}

resource "aws_elastic_beanstalk_environment" "twilreapi_worker" {
  # General Settings

  name                = "${local.twilreapi_app_identifier}-worker"
  application         = aws_elastic_beanstalk_application.twilreapi.name
  tier                = "Worker"
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.twilreapi.name

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
    name      = "AssociatePublicIpAddress"
    value     = "false"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "public"
  }

  ################### EC2 Settings ###################
  # http://amzn.to/2FjIpj6
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.twilreapi_db.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.small"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.twilreapi.name
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
    value     = "4"
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
    value     = "80"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Protocol"
    value     = "HTTP"
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
  # Rails Specific
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RAILS_SKIP_ASSET_COMPILATION"
    value     = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RAILS_ENV"
    value     = "production"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RACK_ENV"
    value     = "production"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE_URL"
    value     = local.twilreapi_db_url
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RAILS_MASTER_KEY"
    value     = aws_ssm_parameter.twilreapi_rails_master_key.value
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_POOL"
    value     = "32"
  }
  # Application Specific
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "UPLOADS_BUCKET"
    value     = aws_s3_bucket.cdr.id
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PROCESS_ACTIVE_ELASTIC_JOBS"
    value     = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DEFAULT_URL_HOST"
    value     = "twilreapi.somleng.org"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DEFAULT_QUEUE_URL"
    value     = "`{\"Ref\" : \"AWSEBWorkerQueue\"}`"
  }
  # Twilreapi Specific
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "OUTBOUND_CALL_DRB_URI"
    value     = local.outbound_call_drb_uri
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "OUTBOUND_CALL_QUEUE_URL"
    value     = aws_elastic_beanstalk_environment.twilreapi_caller_worker.queues.0
  }
}

resource "aws_elastic_beanstalk_environment" "twilreapi_webserver" {
  # General Settings

  name                = "${local.twilreapi_app_identifier}-webserver"
  application         = aws_elastic_beanstalk_application.twilreapi.name
  tier                = "WebServer"
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.twilreapi.name

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
    value     = join(",", module.vpc.public_subnets)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = false
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "public"
  }

  ################### EC2 Settings ###################
  # http://amzn.to/2FjIpj6
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.twilreapi_db.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.small"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.twilreapi.name
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
    value     = "4"
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
    value     = "80"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Protocol"
    value     = "HTTP"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = "/health_checks"
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
    value     = "application"
  }
  ################### Listener ###################
  # https://amzn.to/2GzHQiB
  # Default Listener
  setting {
    namespace = "aws:elbv2:listener:default"
    name      = "ListenerEnabled"
    value     = "true"
  }
  # SSL Listener
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "ListenerEnabled"
    value     = "true"
  }
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "Protocol"
    value     = "HTTPS"
  }
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLCertificateArns"
    value     = data.terraform_remote_state.core.outputs.acm_certificate.arn
  }
  # Security Policies
  # https://amzn.to/2q742us
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLPolicy"
    value     = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
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
  # Rails Specific
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RAILS_SKIP_ASSET_COMPILATION"
    value     = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RAILS_ENV"
    value     = "production"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RACK_ENV"
    value     = "production"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE_URL"
    value     = local.twilreapi_db_url
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RAILS_MASTER_KEY"
    value     = aws_ssm_parameter.twilreapi_rails_master_key.value
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_POOL"
    value     = "32"
  }
  # Application Specific
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "UPLOADS_BUCKET"
    value     = aws_s3_bucket.cdr.id
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DEFAULT_URL_HOST"
    value     = "twilreapi.somleng.org"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DEFAULT_QUEUE_URL"
    value     = aws_elastic_beanstalk_environment.twilreapi_worker.queues.0
  }
  # Twilreapi Specific
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "OUTBOUND_CALL_DRB_URI"
    value     = local.outbound_call_drb_uri
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "OUTBOUND_CALL_QUEUE_URL"
    value     = aws_elastic_beanstalk_environment.twilreapi_caller_worker.queues.0
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "INTERNAL_API_HTTP_AUTH_USER"
    value     = "admin"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "INTERNAL_API_HTTP_AUTH_PASSWORD"
    value     = aws_ssm_parameter.twilreapi_internal_api_password.value
  }
}

resource "aws_route53_record" "twilreapi" {
  zone_id = data.terraform_remote_state.core.outputs.somleng_zone.id
  name    = "twilreapi"
  type    = "A"

  alias {
    name                   = aws_elastic_beanstalk_environment.twilreapi_webserver.cname
    zone_id                = data.aws_elastic_beanstalk_hosted_zone.current.id
    evaluate_target_health = true
  }
}