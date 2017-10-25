require_relative "../client"

class Somleng::RTDClient::Request::Base
  private

  def client
    @client ||= Somleng::RTDClient::Client.new
  end
end
