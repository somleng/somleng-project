class SomlengProject::RealTimeData
  attr_accessor :data

  def initialize(data)
    self.data = data
  end

  def calls_inbound_count
    data["calls_inbound_count"]
  end

  def calls_inbound_minutes
    data["calls_inbound_minutes"]
  end

  def calls_outbound_count
    data["calls_outbound_count"]
  end

  def calls_outbound_minutes
    data["calls_outbound_minutes"]
  end

  def total_amount_saved
    data["total_amount_saved"]
  end
end
