# Watership

Watership is a wrapper around Bunny. It attempts to catch connection issues to the RabbitMQ server and provide a fake backend, switching back to the real backend when it becomes available.

**You shouldn't use it. It's dumb.**

## Installation

Add this line to your application's Gemfile:

    gem 'watership'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install watership

## Usage

This is meant for our specific use case, but if you want to give it a go....

Watership gives you channels. Instead of

    client = Bunny.new([options])
    channel = client.create_channel

You just do

    channel = Watership::Inle.connect([options])

Watership doesn't automatically try to reconnect, but it does provide a couple of "helpful" methods:

* `Watership::Inle.ensure_connection` looks to see if you have a connection (that says it's connected), and if not will try to build one (pace some throttling). Note that the included fake client always reports that it's not connected.
* `Watership::Inle.reconnect([boolean])` calls connect with the options originally provided, but allows you to pass `true` to force a connection to the fake.

## Naming

Inlé is the Grim Reaper of rabbits in *Watership Down*.

I always hear "rabbit" when someone refers to Welsh rarebit, so I think of it as a fake rabbit.

## Contributing

1. Fork it ( http://github.com/bscofield/watership/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
