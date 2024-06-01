module FileFixtureHelpers
  def file_fixture(filename)
    Pathname(File.expand_path("../fixtures/files/#{filename}", __dir__))
  end
end

RSpec.configure do |config|
  config.include(FileFixtureHelpers)
end
