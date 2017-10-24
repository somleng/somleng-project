require 'spec_helper'
require "somleng_project/renderers/introduction_for_development_organizations_renderer"

describe SomlengProject::IntroductionForDevelopmentOrganizationsRenderer do
  describe "#render" do
    def assert_render!
      p subject.render
    end

    it { assert_render! }
  end
end
