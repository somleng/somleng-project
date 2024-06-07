
require "aws-sdk-autoscaling"
require "aws-sdk-ec2"

class AlarmHandler
  attr_reader :autoscaling_client, :ec2_client, :eni_id

  def initialize(**options)
    @eni_id = options.fetch(:eni_id) { ENV.fetch("NAT_INSTANCE_ENI_ID") }
    @autoscaling_client = options.fetch(:autoscaling_client) { Aws::AutoScaling::Client.new }
    @ec2_client = options.fetch(:ec2_client) { Aws::EC2::Client.new }
  end

  def call
    mark_instance_unhealthy
  end

  private

  def mark_instance_unhealthy
    autoscaling_client.set_instance_health(
      instance_id:,
      health_status: "Unhealthy"
    )
  end

  def network_interface_attachment
    @network_interface_attachment ||= ec2_client.describe_network_interface_attribute(
      attribute: "attachment",
      network_interface_id: eni_id,
    )
  end

  def instance_id
    network_interface_attachment.attachment.instance_id
  end
end
