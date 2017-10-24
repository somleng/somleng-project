require_relative "../clients/real_time_data_client"
require_relative "real_time_data"

class SomlengProject::DocumentData
  delegate :ews_project_id,
           :avf_project_id,
           :to => :class

  def ews_data
    @ews_data ||= fetch_real_time_data!(ews_project_id)
  end

  def avf_data
    @avf_data ||= fetch_real_time_data!(avf_project_id)
  end

  private

  def fetch_real_time_data!(project_id)
    SomlengProject::RealTimeData.new(client.fetch_project_real_time_data!(project_id))
  end

  def self.ews_project_id
    ENV["EWS_PROJECT_ID"]
  end

  def self.avf_project_id
    ENV["AVF_PROJECT_ID"]
  end

  def client
    @client ||= SomlengProject::RealTimeDataClient.new
  end
end
