require_relative "../spec_helper"

RSpec.describe NATInstanceHealthChecker do
  it "checks NAT instance connectivity" do
    cloudwatch_client = Aws::CloudWatch::Client.new(stub_responses: true)

    health_checker = NATInstanceHealthChecker.new(
      nat_instance_ip: Net::HTTP.get(URI("https://checkip.amazonaws.com")).strip,
      eni_id: "nat-instance-eni-id",
      cloudwatch_client:
    )

    health_checker.call

    expect(cloudwatch_client.api_requests.size).to eq(1)
    expect(cloudwatch_client.api_requests.first).to include(
      operation_name: :put_metric_data,
      params: include(
        namespace: "NatInstance",
        metric_data: [
          include(
            metric_name: "NatInstanceHealthyRoutes",
            dimensions: [
              {
                name: "EniId",
                value: "nat-instance-eni-id"
              },
            ],
            timestamp: a_kind_of(Time),
            value: 1.0,
            unit: "Count",
            storage_resolution: 60
          )
        ]
      )
    )
  end

  it "handles timeouts" do
    cloudwatch_client = Aws::CloudWatch::Client.new(stub_responses: true)
    health_check_target = URI("https://api.ipify.org")
    health_check_client = Net::HTTP.new(health_check_target.host, health_check_target.port)
    health_check_client.read_timeout = 0
    health_check_client.open_timeout = 0
    health_check_client.use_ssl = health_check_target.scheme == "https"

    health_checker = NATInstanceHealthChecker.new(
      nat_instance_ip: Net::HTTP.get(URI("https://checkip.amazonaws.com")).strip,
      eni_id: "nat-instance-eni-id",
      cloudwatch_client:,
      health_check_client:
    )

    health_checker.call

    expect(cloudwatch_client.api_requests.size).to eq(1)
    expect(cloudwatch_client.api_requests.first).to include(
      operation_name: :put_metric_data,
      params: include(
        metric_data: [
          include(
            value: 0.0,
          )
        ]
      )
    )
  end
end
