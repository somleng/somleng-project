require "json"
require "ipaddr"
require "net/http"
require "aws-sdk-cloudwatch"

class NATInstanceHealthChecker
  PingResponse = Struct.new(:success, keyword_init: true) do
    def success?
      success
    end
  end

  attr_reader :health_check_target, :nat_instance_ip, :eni_id,
              :metric_namespace, :metric_name, :cloudwatch_client,
              :health_check_client

  def initialize(**options)
    health_check_target = options.fetch(:health_check_target) { ENV.fetch("HEALTH_CHECK_TARGET", "54.169.198.37") }
    health_check_target = IPAddr.new(health_check_target).to_s
    health_check_target.prepend("http://")
    @health_check_target = URI(health_check_target)
    @nat_instance_ip = options.fetch(:nat_instance_ip) { ENV.fetch("NAT_INSTANCE_IP") }
    @eni_id = options.fetch(:eni_id) { ENV.fetch("NAT_INSTANCE_ENI_ID") }
    @metric_namespace = options.fetch(:metric_namespace) { ENV.fetch("CLOUDWATCH_METRIC_NAMESPACE", "NatInstance") }
    @metric_name = options.fetch(:metric_name) { ENV.fetch("CLOUDWATCH_METRIC_NAME", "NatInstanceHealthyRoutes") }
    @cloudwatch_client = options.fetch(:cloudwatch_client) { Aws::CloudWatch::Client.new }
    @health_check_client = options.fetch(:health_check_client) do
      client = Net::HTTP.new(@health_check_target.host, @health_check_target.port)
      client.read_timeout = 5
      client.open_timeout = 5
      client
    end
  end

  def call
    publish_metric_data(ping.success? ? 1 : 0)
  end

  private

  def ping
    response = health_check_client.get("/")
    PingResponse.new(success: response.body.strip == nat_instance_ip)
  rescue Timeout::Error
    PingResponse.new(success: false)
  end

  def publish_metric_data(value)
    cloudwatch_client.put_metric_data(
      {
        namespace: metric_namespace,
        metric_data: [
          {
            metric_name:,
            dimensions: [
              {
                name: "EniId",
                value: eni_id
              },
            ],
            timestamp: Time.now,
            value:,
            unit: "Count",
            storage_resolution: 60
          }
        ]
      }
    )
  end
end
