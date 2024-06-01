require "json"

module EventHelpers
  def build_scheduled_event_payload
    JSON.parse(file_fixture("scheduled_event.json").read)
  end
end

RSpec.configure do |config|
  config.include(EventHelpers)
end
