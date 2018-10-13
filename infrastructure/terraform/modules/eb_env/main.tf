locals {
  is_web_tier = "${var.tier == "WebServer" ? "true" : "false"}"

  # Workaround for worker tier
  default_namespace = "aws:elasticbeanstalk:application:environment"
  default_env_name  = "UNUSED_ENV_VAR"
}

resource "aws_elastic_beanstalk_environment" "eb_env" {
  # General Settings

  name                = "${var.env_identifier}-${lower(var.tier)}"
  application         = "${var.app_name}"
  tier                = "${var.tier}"
  solution_stack_name = "${var.solution_stack_name}"

  ################### VPC ###################
  # https://amzn.to/2JzNUcK
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${var.vpc_id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${join(",", var.ec2_subnets)}"
  }

  setting {
    namespace = "${length(var.elb_subnets) == 0 ? local.default_namespace : "aws:ec2:vpc"}"
    name      = "${length(var.elb_subnets) == 0 ? local.default_env_name : "ELBSubnets"}"
    value     = "${join(",", var.elb_subnets)}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "${var.associate_public_ip_address}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "${var.elb_scheme}"
  }

  ################### EC2 Settings ###################
  # http://amzn.to/2FjIpj6
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = "${join(",", var.security_groups)}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "${var.instance_type}"
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
    value     = "${var.autoscaling_group_min_size}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "${var.autoscaling_group_max_size}"
  }

  ################### Auto Scaling Scheduled Action ###################
  # https://amzn.to/2LohqlC
  # ScheduledScaleDown
  setting {
    namespace = "${var.autoscaling_scale_down_recurrence == "" ? local.default_namespace : "aws:autoscaling:scheduledaction"}"
    resource  = "ScheduledScaleDown"
    name      = "${var.autoscaling_scale_down_recurrence == "" ? local.default_env_name : "Recurrence"}"
    value     = "${var.autoscaling_scale_down_recurrence == "" ? "" : "${var.autoscaling_scale_down_recurrence}"}"
  }

  setting {
    namespace = "${var.autoscaling_scale_down_recurrence == "" ? local.default_namespace : "aws:autoscaling:scheduledaction"}"
    resource  = "ScheduledScaleDown"
    name      = "${var.autoscaling_scale_down_recurrence == "" ? local.default_env_name : "DesiredCapacity"}"
    value     = "${var.autoscaling_scale_down_recurrence == "" ? "" : "0"}"
  }

  setting {
    namespace = "${var.autoscaling_scale_down_recurrence == "" ? local.default_namespace : "aws:autoscaling:scheduledaction"}"
    resource  = "ScheduledScaleDown"
    name      = "${var.autoscaling_scale_down_recurrence == "" ? local.default_env_name : "MinSize"}"
    value     = "${var.autoscaling_scale_down_recurrence == "" ? "" : "0"}"
  }

  setting {
    namespace = "${var.autoscaling_scale_down_recurrence == "" ? local.default_namespace : "aws:autoscaling:scheduledaction"}"
    resource  = "ScheduledScaleDown"
    name      = "${var.autoscaling_scale_down_recurrence == "" ? local.default_env_name : "MaxSize"}"
    value     = "${var.autoscaling_scale_down_recurrence == "" ? "" : "${var.autoscaling_group_max_size}"}"
  }

  # ScheduledScaleUp
  setting {
    namespace = "${var.autoscaling_scale_up_recurrence == "" ? local.default_namespace : "aws:autoscaling:scheduledaction"}"
    resource  = "ScheduledScaleUp"
    name      = "${var.autoscaling_scale_up_recurrence == "" ? local.default_env_name : "Recurrence"}"
    value     = "${var.autoscaling_scale_up_recurrence == "" ? "" : "${var.autoscaling_scale_up_recurrence}"}"
  }

  setting {
    namespace = "${var.autoscaling_scale_up_recurrence == "" ? local.default_namespace : "aws:autoscaling:scheduledaction"}"
    resource  = "ScheduledScaleUp"
    name      = "${var.autoscaling_scale_up_recurrence == "" ? local.default_env_name : "DesiredCapacity"}"
    value     = "${var.autoscaling_scale_up_recurrence == "" ? "" : "${var.autoscaling_group_min_size}"}"
  }

  setting {
    namespace = "${var.autoscaling_scale_up_recurrence == "" ? local.default_namespace : "aws:autoscaling:scheduledaction"}"
    resource  = "ScheduledScaleUp"
    name      = "${var.autoscaling_scale_up_recurrence == "" ? local.default_env_name : "MinSize"}"
    value     = "${var.autoscaling_scale_up_recurrence == "" ? "" : "${var.autoscaling_group_min_size}"}"
  }

  setting {
    namespace = "${var.autoscaling_scale_up_recurrence == "" ? local.default_namespace : "aws:autoscaling:scheduledaction"}"
    resource  = "ScheduledScaleUp"
    name      = "${var.autoscaling_scale_up_recurrence == "" ? local.default_env_name : "MaxSize"}"
    value     = "${var.autoscaling_scale_up_recurrence == "" ? "" : "${var.autoscaling_group_max_size}"}"
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
    value     = "${var.cloudwatch_enabled}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "DeleteOnTerminate"
    value     = "${var.cloudwatch_delete_on_terminate}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = "${var.cloudwatch_retention_in_days}"
  }

  ################### Default Process ###################
  # https://amzn.to/2HcmWaG
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = "${var.default_process_port}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Protocol"
    value     = "${var.default_process_protocol}"
  }

  setting {
    namespace = "${var.health_check_path == "" || var.load_balancer_type == "network" ? local.default_namespace : "aws:elasticbeanstalk:environment:process:default"}"
    name      = "${var.health_check_path == "" || var.load_balancer_type == "network" ? local.default_env_name : "HealthCheckPath"}"
    value     = "${var.health_check_path == "" || var.load_balancer_type == "network" ? "" : "${var.health_check_path}"}"
  }

  ################### EB Environment ###################
  # https://amzn.to/2FR9RTu

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "${var.environment_type}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "${var.service_role}"
  }
  setting {
    namespace = "${var.load_balancer_type == "" || !local.is_web_tier ? local.default_namespace : "aws:elasticbeanstalk:environment"}"
    name      = "${var.load_balancer_type == "" || !local.is_web_tier ? local.default_env_name : "LoadBalancerType"}"
    value     = "${var.load_balancer_type}"
  }
  ################### Listener ###################
  # https://amzn.to/2GzHQiB
  # Default Listener
  setting {
    namespace = "${!local.is_web_tier ? local.default_namespace : "aws:elbv2:listener:default"}"
    name      = "${!local.is_web_tier ? local.default_env_name : "ListenerEnabled"}"
    value     = "${!local.is_web_tier ? "" : "${var.default_listener_enabled}"}"
  }
  # SSL Listener
  setting {
    namespace = "${var.ssl_listener_enabled == "false" || !local.is_web_tier ? local.default_namespace : "aws:elbv2:listener:443"}"
    name      = "${var.ssl_listener_enabled == "false" || !local.is_web_tier ? local.default_env_name : "ListenerEnabled"}"
    value     = "${var.ssl_listener_enabled == "false" || !local.is_web_tier ? "" : "${var.ssl_listener_enabled}"}"
  }
  setting {
    namespace = "${var.ssl_listener_enabled == "false" || !local.is_web_tier ? local.default_namespace : "aws:elbv2:listener:443"}"
    name      = "${var.ssl_listener_enabled == "false" || !local.is_web_tier ? local.default_env_name : "Protocol"}"
    value     = "${var.ssl_listener_enabled == "false" || !local.is_web_tier ? "" : "${var.ssl_listener_protocol}"}"
  }
  setting {
    namespace = "${var.ssl_certificate_id == "" ? local.default_namespace : "aws:elbv2:listener:443"}"
    name      = "${var.ssl_certificate_id == "" ? local.default_env_name : "SSLCertificateArns"}"
    value     = "${var.ssl_certificate_id}"
  }
  # Security Policies
  # https://amzn.to/2q742us
  setting {
    namespace = "${var.ssl_listener_enabled == "false" || !local.is_web_tier ? local.default_namespace : "aws:elbv2:listener:443"}"
    name      = "${var.ssl_listener_enabled == "false" || !local.is_web_tier ? local.default_env_name : "SSLPolicy"}"
    value     = "${var.ssl_listener_enabled == "false" || !local.is_web_tier ? "" : "${var.ssl_security_policy}"}"
  }
  # DRb Listener
  setting {
    namespace = "${var.drb_listener_enabled == "false" ? local.default_namespace : "aws:elbv2:listener:${var.drb_listener_port}"}"
    name      = "${var.drb_listener_enabled == "false" ? local.default_env_name : "ListenerEnabled"}"
    value     = "${var.drb_listener_enabled == "false" ? "" : "${var.drb_listener_enabled}"}"
  }
  setting {
    namespace = "${var.drb_listener_enabled == "false" ? local.default_namespace : "aws:elbv2:listener:${var.drb_listener_port}"}"
    name      = "${var.drb_listener_enabled == "false" ? local.default_env_name : "Protocol"}"
    value     = "${var.drb_listener_enabled == "false" ? "" : "${var.drb_listener_protocol}"}"
  }
  # XMPP Listener
  setting {
    namespace = "${var.xmpp_listener_enabled == "false" ? local.default_namespace : "aws:elbv2:listener:${var.xmpp_listener_port}"}"
    name      = "${var.xmpp_listener_enabled == "false" ? local.default_env_name : "ListenerEnabled"}"
    value     = "${var.xmpp_listener_enabled == "false" ? "" : "${var.xmpp_listener_enabled}"}"
  }
  setting {
    namespace = "${var.xmpp_listener_enabled == "false" ? local.default_namespace : "aws:elbv2:listener:${var.xmpp_listener_port}"}"
    name      = "${var.xmpp_listener_enabled == "false" ? local.default_env_name : "Protocol"}"
    value     = "${var.xmpp_listener_enabled == "false" ? "" : "${var.xmpp_listener_protocol}"}"
  }
  ################### ENV Vars ###################
  # https://amzn.to/2Ez6CgW
  # Defaults
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_REGION"
    value     = "${var.aws_region}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "EB_TIER"
    value     = "${var.tier}"
  }
  # Rails Specific
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.rails_skip_asset_compilation == "" ? local.default_env_name : "RAILS_SKIP_ASSET_COMPILATION"}"
    value     = "${var.rails_skip_asset_compilation}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.rails_env == "" ? local.default_env_name : "RAILS_ENV"}"
    value     = "${var.rails_env}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.rails_env == "" ? local.default_env_name : "RACK_ENV"}"
    value     = "${var.rails_env}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.database_url == "" ? local.default_env_name : "DATABASE_URL"}"
    value     = "${var.database_url}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.rails_master_key == "" ? local.default_env_name : "RAILS_MASTER_KEY"}"
    value     = "${var.rails_master_key}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.db_pool == "" ? local.default_env_name : "DB_POOL"}"
    value     = "${var.db_pool}"
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
    name      = "${var.process_active_elastic_jobs == "" ? local.default_env_name : "PROCESS_ACTIVE_ELASTIC_JOBS"}"
    value     = "${var.process_active_elastic_jobs}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.default_url_host == "" ? local.default_env_name : "DEFAULT_URL_HOST"}"
    value     = "${var.default_url_host}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.mailer_sender == "" ? local.default_env_name : "MAILER_SENDER"}"
    value     = "${var.mailer_sender}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.action_mailer_delivery_method == "" ? local.default_env_name : "ACTION_MAILER_DELIVERY_METHOD"}"
    value     = "${var.action_mailer_delivery_method}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.smtp_address == "" ? local.default_env_name : "SMTP_ADDRESS"}"
    value     = "${var.smtp_address}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.smtp_port == "" ? local.default_env_name : "SMTP_PORT"}"
    value     = "${var.smtp_port}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.smtp_username == "" ? local.default_env_name : "SMTP_USERNAME"}"
    value     = "${var.smtp_username}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.smtp_password == "" ? local.default_env_name : "SMTP_PASSWORD"}"
    value     = "${var.smtp_password}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.smtp_authentication_method == "" ? local.default_env_name : "SMTP_AUTHENTICATION_METHOD"}"
    value     = "${var.smtp_authentication_method}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.smtp_enable_starttls_auto == "" ? local.default_env_name : "SMTP_ENABLE_STARTTLS_AUTO"}"
    value     = "${var.smtp_enable_starttls_auto}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DEFAULT_QUEUE_URL"
    value     = "${local.is_web_tier ? "${var.default_queue_url}" : "`{\"Ref\" : \"AWSEBWorkerQueue\"}`"}"
  }
  # Twilreapi Specific
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.outbound_call_drb_uri == "" ? local.default_env_name : "OUTBOUND_CALL_DRB_URI"}"
    value     = "${var.outbound_call_drb_uri}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.aws_sns_message_processor_job_queue_url == "" ? local.default_env_name : "AWS_SNS_MESSAGE_PROCESSOR_JOB_QUEUE_URL"}"
    value     = "${var.aws_sns_message_processor_job_queue_url}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.call_data_record_job_queue_url == "" ? local.default_env_name : "CALL_DATA_RECORD_JOB_QUEUE_URL"}"
    value     = "${var.call_data_record_job_queue_url}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.outbound_call_job_queue_url == "" ? local.default_env_name : "OUTBOUND_CALL_JOB_QUEUE_URL"}"
    value     = "${var.outbound_call_job_queue_url}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.recording_processor_job_queue_url == "" ? local.default_env_name : "RECORDING_PROCESSOR_JOB_QUEUE_URL"}"
    value     = "${var.recording_processor_job_queue_url}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.recording_status_callback_notifier_job_queue_url == "" ? local.default_env_name : "RECORDING_STATUS_CALLBACK_NOTIFIER_JOB_QUEUE_URL"}"
    value     = "${var.recording_status_callback_notifier_job_queue_url}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.status_callback_notifier_job_queue_url == "" ? local.default_env_name : "STATUS_CALLBACK_NOTIFIER_JOB_QUEUE_URL"}"
    value     = "${var.status_callback_notifier_job_queue_url}"
  }
  # SCFM Specific
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.fetch_remote_call_job_queue_url == "" ? local.default_env_name : "FETCH_REMOTE_CALL_JOB_QUEUE_URL"}"
    value     = "${var.fetch_remote_call_job_queue_url}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.queue_remote_call_job_queue_url == "" ? local.default_env_name : "QUEUE_REMOTE_CALL_JOB_QUEUE_URL"}"
    value     = "${var.queue_remote_call_job_queue_url}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.run_batch_operation_job_queue_url == "" ? local.default_env_name : "RUN_BATCH_OPERATION_JOB_QUEUE_URL"}"
    value     = "${var.run_batch_operation_job_queue_url}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.scheduler_job_queue_url == "" ? local.default_env_name : "SCHEDULER_JOB_QUEUE_URL"}"
    value     = "${var.scheduler_job_queue_url}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.audio_bucket == "" ? local.default_env_name : "AUDIO_BUCKET"}"
    value     = "${var.audio_bucket}"
  }
  # Somleng Adhearsion Specific
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.adhearsion_app == "false" || var.adhearsion_env == "" ? local.default_env_name : "AHN_ENV"}"
    value     = "${var.adhearsion_env}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.adhearsion_app == "false" || var.adhearsion_core_host == "" ? local.default_env_name : "AHN_CORE_HOST"}"
    value     = "${var.adhearsion_core_host}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.adhearsion_app == "false" || var.adhearsion_core_port == "" ? local.default_env_name : "AHN_CORE_PORT"}"
    value     = "${var.adhearsion_core_port}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.adhearsion_app == "false" || var.adhearsion_core_username == "" ? local.default_env_name : "AHN_CORE_USERNAME"}"
    value     = "${var.adhearsion_core_username}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.adhearsion_app == "false" || var.adhearsion_core_password == "" ? local.default_env_name : "AHN_CORE_PASSWORD"}"
    value     = "${var.adhearsion_core_password}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.adhearsion_app == "false" || var.adhearsion_drb_port == "" ? local.default_env_name : "AHN_ADHEARSION_DRB_PORT"}"
    value     = "${var.adhearsion_drb_port}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.adhearsion_app == "false" || var.adhearsion_twilio_rest_api_phone_calls_url == "" ? local.default_env_name : "AHN_TWILIO_REST_API_PHONE_CALLS_URL"}"
    value     = "${var.adhearsion_twilio_rest_api_phone_calls_url}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "${var.adhearsion_app == "false" || var.adhearsion_twilio_rest_api_phone_call_events_url == "" ? local.default_env_name : "AHN_TWILIO_REST_API_PHONE_CALL_EVENTS_URL"}"
    value     = "${var.adhearsion_twilio_rest_api_phone_call_events_url}"
  }
}
