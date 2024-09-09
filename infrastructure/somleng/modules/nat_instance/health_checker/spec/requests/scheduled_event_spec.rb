require_relative "../spec_helper"

RSpec.describe "App" do
  it "handles scheduled events" do
    health_checker = NATInstanceHealthChecker.new
    allow(NATInstanceHealthChecker).to receive(:new).and_return(health_checker)
    allow(health_checker).to receive(:call).and_call_original
    payload = build_scheduled_event_payload

    invoke_lambda(payload:)

    expect(health_checker).to have_received(:call)
  end
end
