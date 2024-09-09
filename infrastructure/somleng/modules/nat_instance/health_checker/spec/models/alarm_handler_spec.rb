require_relative "../spec_helper"

RSpec.describe AlarmHandler do
  it "marks the NAT instance unhealthy" do
    autoscaling_client = Aws::AutoScaling::Client.new(stub_responses: true)

    alarm_handler = AlarmHandler.new(
      eni_id: "nat-instance-eni-id",
      autoscaling_client:
    )

    alarm_handler.call

    expect(autoscaling_client.api_requests.size).to eq(1)
    expect(autoscaling_client.api_requests.first).to include(
      operation_name: :set_instance_health,
      params: include(
        health_status: "Unhealthy"
      )
    )
  end
end
