# Watership

Watership is a wrapper around Bunny. It attempts to catch connection issues to the RabbitMQ server and provide a fake backend, switching back to the real backend when it becomes available.

It is currently being used in production on a set of applications, but be warned that it's still early in its life.

## Installation

Add this line to your application's Gemfile:

    gem 'watership'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install watership

## Usage

This is meant for our specific use case, but if you want to give it a go....

Once you've `require`d it, you configure Watership with:

    Watership.config = '[AMQP URI]'

Optionally, you can set a logger (`Watership.logger = ...`) and specify the environment (`Watership.environment = ...`).

Then, connect to your RabbitMQ instance with:

    Watership.reconnect

Finally, you push messages like this:

    Watership.enqueue(name: 'queue name', message: 'message to enqueue')

## Contributing

1. Fork it ( http://github.com/bscofield/watership/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
