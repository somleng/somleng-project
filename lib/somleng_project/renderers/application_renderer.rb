require 'erb'

class SomlengProject::ApplicationRenderer
  DEFAULT_TEMPLATE_EXTENSION = "erb"
  attr_accessor :date

  delegate :template_name,
           :template_extension,
           :template_path,
           :output_path,
           :to => :class

  def initialize(options = {})
    self.date = options[:date]
  end

  def render
    ERB.new(template).result(binding)
  end

  def generate_doc!

  end

  def date
    @date ||= Date.today
  end

  private

  def template
    @template ||= File.read(template_path)
  end

  def self.template_extension
    DEFAULT_TEMPLATE_EXTENSION
  end

  def self.template_name
    self::TEMPLATE_NAME
  end

  def self.output_path
    File.expand_path("../../../docs/#{template_name}", File.dirname(__FILE__))
  end

  def self.template_path
    File.expand_path("../templates/#{template_name}.#{template_extension}", File.dirname(__FILE__))
  end
end
