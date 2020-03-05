locals {
  twilreapi_major_ruby_version = "2.6"
  twilreapi_app_identifier = "twilreapi"
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
    value     = join(",", aws_security_group.db.id)
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.small"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${var.ec2_instance_role}"
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

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = "360"
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
    value     = data.certificate_arn
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
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EB_TIER"
    value     = "WebServer"
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
    value     = "${var.database_url}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RAILS_MASTER_KEY"
    value     = aws_ssm_parameter.twilreapi_rails_master_key.value
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_POOL"
    value     = "48"
  }
  # Application Specific
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.s3_access_key_id == "" ? local.default_env_name : "AWS_S3_ACCESS_KEY_ID"}"
    value     = "${var.s3_access_key_id}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.s3_secret_access_key == "" ? local.default_env_name : "AWS_S3_SECRET_ACCESS_KEY"}"
    value     = "${var.s3_secret_access_key}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.uploads_bucket == "" ? local.default_env_name : "UPLOADS_BUCKET"}"
    value     = "${var.uploads_bucket}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.default_url_host == "" ? local.default_env_name : "DEFAULT_URL_HOST"}"
    value     = "${var.default_url_host}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DEFAULT_QUEUE_URL"
    value     = "${var.default_queue_url}"
  }
  # Twilreapi Specific
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.outbound_call_drb_uri == "" ? local.default_env_name : "OUTBOUND_CALL_DRB_URI"}"
    value     = "${var.outbound_call_drb_uri}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.initiate_outbound_call_queue_url == "" ? local.default_env_name : "INITIATE_OUTBOUND_CALL_QUEUE_URL"}"
    value     = "${var.initiate_outbound_call_queue_url}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.initiate_outbound_call_queue_url == "" ? local.default_env_name : "OUTBOUND_CALL_JOB_QUEUE_URL"}"
    value     = "${var.initiate_outbound_call_queue_url}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.twilreapi_internal_api_http_auth_user == "" ? local.default_env_name : "INTERNAL_API_HTTP_AUTH_USER"}"
    value     = "${var.twilreapi_internal_api_http_auth_user}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.twilreapi_internal_api_http_auth_password == "" ? local.default_env_name : "INTERNAL_API_HTTP_AUTH_PASSWORD"}"
    value     = "${var.twilreapi_internal_api_http_auth_password}"
  }
}

module "twilreapi_eb_app_env" {
  source = "../modules/eb_app_env"

  # General Settings
  app_name            = "${module.twilreapi_eb_app.app_name}"
  solution_stack_name = "${module.eb_solution_stack.ruby_name}"
  env_identifier      = "${local.twilreapi_identifier}"

  # VPC
  vpc_id      = "${module.vpc.vpc_id}"
  elb_subnets = "${module.vpc.public_subnets}"
  ec2_subnets = "${module.vpc.private_subnets}"

  # EC2 Settings
  security_groups   = ["${module.twilreapi_db.security_group}"]
  ec2_instance_role = "${module.eb_iam.eb_ec2_instance_role}"

  # Elastic Beanstalk Environment
  service_role = "${module.eb_iam.eb_service_role}"

  # Listener
  ssl_certificate_id = "${aws_acm_certificate.certificate.arn}"

  # ENV Vars
  ## Defaults
  aws_region = "${var.aws_region}"

  ## Rails Specific
  rails_master_key = "${local.twilreapi_rails_master_key}"
  database_url     = "${local.twilreapi_db_host}"
  db_pool          = "${local.rails_db_pool}"

  ## Application Specific
  s3_access_key_id     = "${module.s3_iam.s3_access_key_id}"
  s3_secret_access_key = "${module.s3_iam.s3_secret_access_key}"
  uploads_bucket       = "${aws_s3_bucket.cdr.id}"
  default_url_host     = "https://${local.twilreapi_fqdn}"
  smtp_username        = "${module.ses.smtp_username}"
  smtp_password        = "${module.ses.smtp_password}"

  ### Twilreapi Specific
  outbound_call_drb_uri                     = "${local.somleng_adhearsion_drb_host}"
  initiate_outbound_call_queue_url          = "${module.twilreapi_eb_outbound_call_worker_env.aws_sqs_queue_url}"
  twilreapi_internal_api_http_auth_user     = "${local.twilreapi_internal_api_http_auth_user}"
  twilreapi_internal_api_http_auth_password = "${local.twilreapi_internal_api_http_auth_password}"
}