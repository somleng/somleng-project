require_relative "base"
require_relative "../response/project"
require_relative "../response/real_time_data"

class Somleng::RTDClient::Request::Project < Somleng::RTDClient::Request::Base
  attr_accessor :project_id

  def initialize(project_id)
    self.project_id = project_id
  end

  def fetch!
    Somleng::RTDClient::Response::Project.new(client.fetch_project!(project_id))
  end

  def fetch_real_time_data!
    Somleng::RTDClient::Response::RealTimeData.new(client.fetch_project_real_time_data!(project_id))
  end
end
