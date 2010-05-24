
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minx'
require 'rack'
require 'rack/builder'

CHAN = Minx.channel

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

handler = Proc.new do |env|
  req = Rack::Request.new(env)
  case req.request_method
  when 'POST'
    message = req.params['message']

    if message.nil?
      [401, {'Content-Type' => 'text/plain'}, "Please specify a message"]
    end

    puts "Writing message #{message}"
    CHAN.write(message)
    puts "Done writing"
    [200, {'Content-Type' => 'text/plain'}, "Wrote message #{message}"]
  when 'GET'
    message = CHAN.read
    [200, {'Content-Type' => 'text/plain'}, "Read message #{message}"]
  end
end

app = Rack::Minx.new(handler)

Rack::Handler::Thin.run(app)
