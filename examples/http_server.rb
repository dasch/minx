
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minx'
require 'minx/rack'
require 'rack/builder'

CHAN = Minx.channel

handler = Proc.new do |env|
  req = Rack::Request.new(env)

  case req.request_method
  when 'POST'
    message = req.params['message']

    CHAN.write(message)
    [200, {'Content-Type' => 'text/plain'}, "Wrote message #{message}"]
  when 'GET'
    message = CHAN.read
    [200, {'Content-Type' => 'text/plain'}, "Read message #{message}"]
  end
end

app = Rack::Minx.new(handler)

Rack::Handler::Thin.run(app)
