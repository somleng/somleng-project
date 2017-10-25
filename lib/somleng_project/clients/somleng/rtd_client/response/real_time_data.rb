require_relative "base"

class Somleng::RTDClient::Response::RealTimeData < Somleng::RTDClient::Response::Base
  def calls_inbound_count
    raw_response["calls_inbound_count"]
  end

  def calls_inbound_minutes
    raw_response["calls_inbound_minutes"]
  end

  def calls_outbound_count
    raw_response["calls_outbound_count"]
  end

  def calls_outbound_minutes
    raw_response["calls_outbound_minutes"]
  end

  def total_amount_saved
    raw_response["total_amount_saved"]
  end

  def total_equivalent_twilio_price
    raw_response["total_equivalent_twilio_price"]
  end
end
