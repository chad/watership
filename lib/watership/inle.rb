require 'logger'
require 'bunny'

module Watership
  class Inle
    @connection_options = {}
    @connection = nil
    @channel = nil
    @last_connection_attempt = nil

    # seconds to wait before (potentially) retrying to connect to the live service
    @retry_timer = 10

    def self.connect(options = {}, fake = false)
      @connection_options.merge!(options)
      @last_connection_attempt = Time.now

      @connection = begin
        Bunny.new @connection_options
      rescue Bunny::TCPConnectionFailed, Bunny::NetworkFailure
        fake = true
      end unless fake

      @connection = FakeRarebit.new if fake

      @connection.start
      @channel = @connection.create_channel
    end

    def self.reconnect(fake = false)
      connect({}, fake)
    end

    def self.ensure_connection
      if !(@connection && @connection.connected?) && time_to_try_again?
        connect
      end
    end

    def self.time_to_try_again?
      Logger.new(STDOUT).info "TIME"
      @last_connection_attempt.nil? || Time.now > @last_connection_attempt + @retry_timer
    end
  end
end