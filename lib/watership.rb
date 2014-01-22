require 'watership/version'

require 'bunny'
require 'json'

class Watership
  CONNECTION_EXCEPTIONS = [
    Bunny::ClientTimeout,
    Bunny::NetworkFailure,
    Bunny::PossibleAuthenticationFailureError,
    Bunny::TCPConnectionFailed
  ]

  def self.config=(path)
    @config = IO.read(path).chomp
  end

  def self.connect_to_rabbit
    $rabbit = Bunny.new(@config)

    $rabbit.start
    $channel = $rabbit.create_channel
  rescue *CONNECTION_EXCEPTIONS => e
    logger.warn(e.class.name)
    $channel = nil
  end

  def self.enqueue(queue_name, data, options = {})
    if $channel
      queue = $channel.queue(queue_name, { durable: true }.merge(options))
      queue.publish(JSON.generate(data))
    end
  rescue StandardError => e
    # $channel.close
    # $channel = nil # kill the channel so we stop trying to push to Rabbit

    Airbrake.notify(e) if defined?(Airbrake)
    logger.error e.class.name
  end

  def self.logger
    @logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
  end

end