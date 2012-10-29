Minx
====

Massive and pervasive concurrency with Minx!

Minx uses the powerful concurrency primitives outlined by Tony Hoare in his
famous book "Communicating Sequential Processes". This library was written
as part of [my bachelor thesis](http://cl.ly/2E2s471i122S3I1s3W30).


Usage
-----

Minx lets you easily create concurrent programs using the notion of *processes*
and *channels*.

```ruby
# Very contrived example...
chan = Minx.channel

Minx.spawn { chan.write("Hello, World!") }
Minx.spawn { puts chan.read }
```

These primitives, although simple, are incredibly powerful when composing highly
concurrent applications. When reading from or writing to a channel, a process
yields execution -- and thus blocks until another process also participates in
the communication. An example of when this would be useful is a simple network
server:

```ruby
# Create a channel for the incoming requests.
requests = Minx.channel

# Spawn 10 workers.
10.times do
  Minx.spawn do
    requests.each {|request| handle_request(request) }
  end
end
```

In the near future, evented IO will be implemented, allowing for highly
performant network and file applications.


Documentation
-------------

See [the full documentation](http://rubydoc.info/github/dasch/minx/master/frames).


Copyright
---------

Copyright (c) 2010 Daniel Schierbeck (@dasch). See {file:LICENSE} for details.
