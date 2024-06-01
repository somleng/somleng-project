module RequestHelpers
  def invoke_lambda(payload:)
    context = double("LambdaContext", as_json: {})

    App::Handler.process(event: payload, context:)
  end
end

RSpec.configure do |config|
  config.include(RequestHelpers)
end
