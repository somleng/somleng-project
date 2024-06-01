RSpec.configure do |config|
  config.before do
    logger = instance_double(Logger).as_null_object
    allow(Logger).to receive(:new).and_return(logger)
  end
end
