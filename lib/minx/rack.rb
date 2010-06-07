
require 'rack'

# A Minx middleware.
#
# Executes each request in its own fiber.
class Rack::Minx
  def initialize(app)
    @app = app
  end

  def call(env)
    Minx.spawn do
      env['async.callback'].call(@app.call(env))
    end

    throw :async
  end
end
