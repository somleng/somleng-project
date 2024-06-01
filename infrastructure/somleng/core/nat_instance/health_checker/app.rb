require "logger"

require_relative "config/application"

module App
  class Handler
    attr_reader :event, :context

    def self.process(event:, context:)
      logger = Logger.new($stdout)
      logger.info("## Processing Event")
      logger.info(event)

      new(event:, context:).process
    end

    def initialize(event:, context:)
      @event = EventParser.new(event).parse_event
      @context = context
    end

    def process
      case event.event_type
      when :scheduled
        NATInstanceHealthChecker.new.call
      end
    end
  end
end
