#!/usr/bin/env ruby

# Usage:
#
# ./pinpoint_sms create
# ./pinpoint_sms destroy

require "bundler/inline"

gemfile do
  source "https://rubygems.org"

  gem "aws-sdk-pinpointsmsvoicev2"
  gem "aws-sdk-cloudwatchlogs"
  gem "aws-sdk-iam"
  gem "pry"
  gem "ox"
end

class PinpointSMSClient
  attr_reader :client

  def initialize(params = {})
    @client = params.fetch(:client) { Aws::PinpointSMSVoiceV2::Client.new }
  end

  def phone_numbers(number_type: "SIMULATOR")
    client.describe_phone_numbers(
      filters: [
        {
          name: "number-type",
          values: [number_type]
        }
      ]
    ).phone_numbers
  end

  def sender_ids(params = {})
    client.describe_sender_ids(**params).sender_ids
  end

  def phone_pools(params = {})
    client.describe_pools(params).pools
  end

  def list_tags(resource_arn:)
    client.list_tags_for_resource(resource_arn:).tags
  end

  def configuration_sets(params = {})
    client.describe_configuration_sets(params).configuration_sets
  end

  def verified_destination_phone_numbers(params = {})
    client.describe_verified_destination_numbers(**params).verified_destination_numbers
  end

  def delete_configuration_set(configuration_set_name:)
    client.delete_configuration_set(configuration_set_name:)
  rescue Aws::PinpointSMSVoiceV2::Errors::ResourceNotFoundException
  end

  def delete_phone_pool(pool_id:)
    client.delete_pool(pool_id:)
  rescue Aws::PinpointSMSVoiceV2::Errors::ResourceNotFoundException
  end

  def request_phone_number(**params)
    client.request_phone_number(
      iso_country_code: "US",
      message_type: "TRANSACTIONAL",
      number_capabilities: ["SMS"],
      number_type: "SIMULATOR",
      **params
    )
  end

  def request_sender_id(**params)
    client.request_sender_id(
      message_types: ["TRANSACTIONAL"],
      **params
    )
  end

  def release_phone_number(phone_number_id:)
    client.release_phone_number(phone_number_id:)
  end

  def release_sender_id(params)
    client.release_sender_id(params)
  end

  def create_phone_pool(origination_identity:, **params)
    client.create_pool(
      origination_identity: origination_identity,
      iso_country_code: "US",
      message_type: "TRANSACTIONAL",
      **params
    )
  end

  def create_configuration_set(params = {})
    client.create_configuration_set(params)
  end

  def create_event_destination(configuration_set_name:, **params)
    client.create_event_destination(
      configuration_set_name:,
      **params,
    )
  end

  def create_verified_destination_number(params)
    client.create_verified_destination_number(params)
  end
end

class CloudwatchClient
  attr_reader :client

  def initialize(params = {})
    @client = params.fetch(:client) { Aws::CloudWatchLogs::Client.new }
  end

  def log_groups(log_group_name_prefix:, **params)
    client.describe_log_groups(log_group_name_prefix:, **params).log_groups
  end
end

class IAMClient
  attr_reader :client

  def initialize(params = {})
    @client = params.fetch(:client) { Aws::IAM::Client.new }
  end

  def find_role(name:)
    client.get_role(role_name: name).role
  end
end

class BootstrapPinpointSMS
  attr_reader :pinpoint_sms_client, :cloudwatch_client, :iam_client,
              :name, :identifier, :sender_id, :sender_id_country_code,
              :phone_pool_name, :configuration_set_name, :log_group_name,
              :cloudwatch_iam_role, :sns_topic_name, :destination_phone_numbers

  def initialize(params = {})
    @pinpoint_sms_client = params.fetch(:pinpoint_sms_client) { PinpointSMSClient.new }
    @cloudwatch_client = params.fetch(:cloudwatch_client) { CloudwatchClient.new }
    @iam_client = params.fetch(:iam_client) { IAMClient.new }
    @name = params.fetch(:name)
    @sender_id_country_code = params.fetch(:sender_id_country_code)
    @identifier = params.fetch(:identifier, "#{name}-pinpoint-sms")
    @sender_id = params.fetch(:sender_id, name)
    @phone_pool_name = params.fetch(:phone_pool_name, identifier)
    @configuration_set_name = params.fetch(:configuration_set_name, identifier)
    @log_group_name = params.fetch(:log_group_name, identifier)
    @cloudwatch_iam_role = params.fetch(:cloudwatch_iam_role, "#{identifier}-cloudwatch")
    @sns_topic_name = params.fetch(:sns_topic_name, identifier)
    @destination_phone_numbers = Array(params.fetch(:destination_phone_numbers))
  end

  def create
    phone_number = find_or_request_phone_number
    sender_id = find_or_request_sender_id
    phone_pool = find_or_create_phone_pool(phone_number:)
    configuration_set = find_or_create_configuration_set
    find_or_create_cloudwatch_event_destination(configuration_set:)
    find_or_create_verified_destination_numbers
    # find_or_create_sns_event_destination(configuration_set:)
  end

  def destroy
    destroy_configuration_set
    destroy_phone_pool
    release_phone_number
    release_sender_id
  end

  private

  def destroy_configuration_set
    pinpoint_sms_client.delete_configuration_set(configuration_set_name: configuration_set_name)
  end

  def destroy_phone_pool
    phone_pool = pinpoint_sms_client.phone_pools.find do |phone_pool|
      tags = pinpoint_sms_client.list_tags(resource_arn: phone_pool.pool_arn)
      tags.any? { |t| t.key == "Name" && t.value == phone_pool_name  }
    end

    return if phone_pool.nil?

    pinpoint_sms_client.delete_phone_pool(pool_id: phone_pool.pool_id)
  end

  def release_phone_number
    return if simulator_phone_numbers.empty?

    pinpoint_sms_client.release_phone_number(
      phone_number_id: simulator_phone_numbers.first.phone_number_id
    )
  end

  def release_sender_id
    return if requested_sender_ids.empty?

    pinpoint_sms_client.release_sender_id(
      sender_id:,
      iso_country_code: sender_id_country_code
    )
  end

  def find_or_request_phone_number
    return simulator_phone_numbers.first if simulator_phone_numbers.any?

    pinpoint_sms_client.request_phone_number(number_type: "SIMULATOR")
  end

  def find_or_request_sender_id
    return requested_sender_ids.first if requested_sender_ids.any?

    pinpoint_sms_client.request_sender_id(
      sender_id:,
      iso_country_code: sender_id_country_code,
      message_types: ["TRANSACTIONAL"]
    )
  end

  def find_or_create_phone_pool(phone_number:)
    phone_pools = pinpoint_sms_client.phone_pools
    return phone_pools.first if phone_pools.any?

    pinpoint_sms_client.create_phone_pool(
      origination_identity: phone_number.phone_number_arn,
      tags: [
        {
          key: "Name",
          value: phone_pool_name
        }
      ]
    )
  end

  def find_or_create_verified_destination_numbers
    destination_phone_numbers.each do |destination_phone_number|
      existing_verified_numbers = pinpoint_sms_client.verified_destination_phone_numbers(
        destination_phone_numbers: [destination_phone_number]
      )

      next if existing_verified_numbers.any?

      pinpoint_sms_client.create_verified_destination_number(
        destination_phone_number: destination_phone_number
      )
    end
  end

  def find_or_create_configuration_set
    configuration_sets = pinpoint_sms_client.configuration_sets
    return configuration_sets.first if configuration_sets.any?

    pinpoint_sms_client.create_configuration_set(configuration_set_name:)
    pinpoint_sms_client.configuration_sets.first
  end

  def find_or_create_cloudwatch_event_destination(configuration_set:)
    return if configuration_set.event_destinations.any? do |event_destination|
      !event_destination&.cloud_watch_logs_destination.nil?
    end

    log_group = find_log_group
    cloudwatch_iam_role = find_cloudwatch_iam_role

    pinpoint_sms_client.create_event_destination(
      configuration_set_name: configuration_set.configuration_set_name,
      event_destination_name: "cloudwatch",
      matching_event_types: ["ALL"],
      cloud_watch_logs_destination: {
        iam_role_arn: cloudwatch_iam_role.arn,
        log_group_arn: log_group.arn
      }
    )
  end

  def find_or_create_sns_event_destination(configuration_set:)
    return if configuration_set.event_destinations.any? do |event_destination|
      !event_destination&.sns_destination.nil?
    end

    sns_topic = find_sns_topic

    pinpoint_sms_client.create_event_destination(
      configuration_set_name: configuration_set.configuration_set_name,
      event_destination_name: "cloudwatch",
      matching_event_types: ["ALL"],
      sns_destination: {
        topic_arn: sns_topic.arn
      }
    )
  end

  def find_cloudwatch_iam_role
    iam_client.find_role(name: cloudwatch_iam_role)
  end

  def find_log_group
    cloudwatch_client.log_groups(log_group_name_prefix: log_group_name).first
  end

  def find_sns_topic
    sns_client.find_topic(name: sns_topic_name)
  end

  def simulator_phone_numbers
    @simulator_phone_numbers ||= pinpoint_sms_client.phone_numbers(number_type: "SIMULATOR")
  end

  def requested_sender_ids
    @requested_sender_ids ||= pinpoint_sms_client.sender_ids(
      filters: [
        {
          name: "sender-id",
          values: [sender_id]
        },
        {
          name: "iso-country-code",
          values: [sender_id_country_code]
        }
      ]
    )
  end
end

action, = ARGV

raise "Invalid action #{action}. Must be either create or destroy" unless %w[create destroy].include?(action)

workflow = BootstrapPinpointSMS.new(
  name: "somleng",
  sender_id_country_code: "KH",
  destination_phone_numbers: "+855715100860"
)

workflow.public_send(action)
