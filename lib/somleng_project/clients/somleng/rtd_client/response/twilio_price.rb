require_relative "base"

class Somleng::RTDClient::Response::TwilioPrice < Somleng::RTDClient::Response::Base
  def voice_url
    raw_response["voice_url"]
  end

  def outbound_voice_price
    raw_response["outbound_voice_price"]
  end
end
