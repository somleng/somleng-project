class EventParser
  class UnhandledEventError < StandardError; end

  Event = Struct.new(:event_type, keyword_init: true)

  attr_reader :event

  def initialize(event)
    @event = event
  end

  def parse_event
    if scheduled_event?
      Event.new(event_type: :scheduled)
    else
      raise UnhandledEventError("Unhandled event: #{event.inspect}")
    end
  end

  private

  def scheduled_event?
    source == "aws.events" && detail_type == "Scheduled Event"
  end

  def source
    event["source"]
  end

  def detail_type
    event["detail-type"]
  end
end
