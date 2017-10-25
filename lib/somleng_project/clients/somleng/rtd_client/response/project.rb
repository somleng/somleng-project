require_relative "base"
require_relative "twilio_price"

class Somleng::RTDClient::Response::Project < Somleng::RTDClient::Response::Base
  def twilio_price
    @twilio_price ||= Somleng::RTDClient::Response::TwilioPrice.new(raw_response["twilio_price"])
  end
end
