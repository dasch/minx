Minx
====

Massive and pervasive concurrency with Minx!

Minx uses the powerful concurrency primitives outlined by Tony Hoare in his
famous book "Communicating Sequential Processes".


Usage
-----

Minx lets you easily create concurrent programs using the notion of *processes*
and *channels*.

    # Very contrived example...
    chan = Minx.channel

    Minx.spawn { chan.write("Hello, World!") }
    Minx.spawn { puts chan.read("Hello, World!") }

These primitives, although simple, are incredibly powerful when composing highly
concurrent applications. When reading from or writing to a channel, a process
yields execution -- and thus blocks until another process also participates in
the communication. An example of when this would be useful is a simple network
server:

    # Create a channel for the incoming requests.
    requests = Minx.channel

    # Spawn 10 workers.
    10.times do
      Minx.spawn do
        requests.each {|request| handle_request(request) }
      end
    end

In the near future, evented IO will be implemented, allowing for highly
performant network and file applications.


Documentation
-------------

See [the full documentation](http://yardoc.org/docs/dasch-minx/file:README.md).


Copyright
---------

Copyright (c) 2010 Daniel Schierbeck. See {file:LICENSE} for details.
