class Somleng::RTDClient::Response::Base
  attr_accessor :raw_response

  def initialize(raw_response)
    self.raw_response = raw_response
  end
end
