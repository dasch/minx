
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minx'
require 'rack'
require 'rack/builder'

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

app = Rack::Minx.new(lambda {|env| [200, {}, "Hello, World!\n"] })

Rack::Handler::Thin.run(app)
