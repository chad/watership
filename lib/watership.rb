require "bunny"
require "json"
require "watership/version"

class Watership
  CONNECTION_EXCEPTIONS = [
    Bunny::ClientTimeout,
    Bunny::NetworkFailure,
    Bunny::PossibleAuthenticationFailureError,
    Bunny::TCPConnectionFailed
  ]

  class << self
    def config=(path)
      @config = IO.read(path).chomp
    end

    def enqueue(options = {})
      options  = options.dup
      message  = options.delete(:message)
      name     = options.delete(:name)
      fallback = options.delete(:fallback)

      queue = connect_with_queue(name, options)
      queue.publish(JSON.generate(message))
    rescue StandardError => exception
      fallback.call if fallback
      Airbrake.notify(exception) if defined?(Airbrake)
      logger.error(exception.class.name)
    end

    def connect_with_queue(name, options)
      channel.queue(name, { durable: true }.merge(options))
    end

    def reconnect
      $channel = nil
      channel
      true
    end

    def channel
      $channel ||= connection.create_channel
    rescue *CONNECTION_EXCEPTIONS => exception
      logger.warn(exception.class.name)
      $channel = nil
    end

    def connection
      Bunny.new(@config).tap { |bunny| bunny.start }
    end

    def logger
      @logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
    end
  end
end
