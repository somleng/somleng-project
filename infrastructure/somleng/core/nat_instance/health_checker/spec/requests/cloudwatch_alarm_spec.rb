require_relative "../spec_helper"

RSpec.describe "App" do
  it "handles cloudwatch alarms" do
    alarm_handler = AlarmHandler.new
    allow(AlarmHandler).to receive(:new).and_return(alarm_handler)
    allow(alarm_handler).to receive(:call).and_call_original

    payload = build_cloudwatch_alarm_payload

    invoke_lambda(payload:)

    expect(alarm_handler).to have_received(:call)
  end
end
