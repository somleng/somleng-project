module EnvHelpers
  def stub_env(env)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:fetch).and_call_original
    env.each do |key, value|
      allow(ENV).to receive(:[]).with(key).and_return(value)
      allow(ENV).to receive(:fetch).with(key).and_return(value)
    end
  end
end

RSpec.configure do |config|
  config.include(EnvHelpers)
end
