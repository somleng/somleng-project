require 'httparty'

class SomlengProject::RealTimeDataClient
  DEFAULT_ENDPOINT = "http://rtd.somleng.org/api"

  def fetch_aggregate_real_time_data!
    fetch_real_time_data!
  end

  def fetch_project_real_time_data!(project_id)
    raise("You must specify a project_id") if project_id.blank?
    fetch_real_time_data!(project_id)
  end

  private

  def fetch_real_time_data!(project_id = nil)
    HTTParty.get(
      real_time_data_endpoint(project_id)
    )
  end

  def endpoint(*paths)
    [DEFAULT_ENDPOINT, *paths].compact.join("/")
  end

  def real_time_data_endpoint(project_id = nil)
    endpoint(project_id && "projects", project_id, "real_time_data.json")
  end
end
