require_relative "application_renderer"

class SomlengProject::IntroductionForDevelopmentOrganizationsRenderer < SomlengProject::ApplicationRenderer
  TEMPLATE_NAME = "introduction_for_development_organizations.md"

  attr_accessor :ews_inbound_calls,
                :ews_inbound_minutes,
                :ews_outbound_calls,
                :ews_outbound_minutes,
                :ews_total_amount_saved

  def initialize(options = {})
    super
    self.ews_inbound_calls = options[:ews_inbound_calls]
    self.ews_inbound_minutes = options[:ews_inbound_minutes]
    self.ews_outbound_calls = options[:ews_outbound_calls]
    self.ews_outbound_minutes = options[:ews_outbound_minutes]
    self.ews_total_amount_saved = options[:ews_total_amount_saved]
  end
end
