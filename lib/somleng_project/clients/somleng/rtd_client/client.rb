require 'httparty'

class Somleng::RTDClient::Client
  DEFAULT_ENDPOINT = "http://rtd.somleng.org/api"

  def fetch_aggregate_real_time_data!
    fetch_real_time_data!
  end

  def fetch_project_real_time_data!(project_id)
    raise_if_no_project_id!(project_id)
    fetch_real_time_data!(project_id)
  end

  def fetch_project!(project_id)
    raise_if_no_project_id!(project_id)
    fetch_projects!(project_id)
  end

  private

  def raise_if_no_project_id!(project_id)
    raise("You must specify a project_id") if project_id.blank?
  end

  def fetch_projects!(project_id = nil)
    do_fetch!(projects_endpoint(project_id))
  end

  def fetch_real_time_data!(project_id = nil)
    do_fetch!(real_time_data_endpoint(project_id))
  end

  def endpoint(*paths)
    [DEFAULT_ENDPOINT, *paths].compact.join("/")
  end

  def real_time_data_endpoint(project_id = nil)
    endpoint(project_id && "projects", project_id, "real_time_data.json")
  end

  def projects_endpoint(project_id = nil)
    endpoint("projects", project_id)
  end

  def do_fetch!(url)
    HTTParty.get(url)
  end
end
