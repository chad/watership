require "json"
require "bunny"
require "logger"

module Watership
  class Consumer
    def initialize(consumer, url, channel_options = {}, queue_options = {})
      @consumer = consumer
      @url = url
      @prefetch = channel_options.delete(:prefetch) || Integer(ENV.fetch("RABBIT_CONSUMER_PREFETCH", 200))
      @channel_opts = {durable: true}.merge(channel_options)
      @queue_opts = {block: true, ack: true}.merge(queue_options)
    end

    def consume
      Thread.abort_on_exception = true
      begin
        queue.subscribe(@queue_opts) do |delivery_info, properties, payload|
          success = true
          data = JSON.parse(payload)
          begin
            @consumer.call(data)
            ack_message(delivery_info.delivery_tag)
          rescue StandardError => exception
            logger.error "Error thrown in subscribe block"
            logger.error exception.message
            logger.error exception.backtrace.join("\n")

            retries = data["retries"] || 0

            if retries.to_i < 3
              Watership.enqueue(name: @consumer.class::QUEUE, payload: data.merge({retries: retries+1}))
            end

            Airbrake.notify(exception) if defined?(Airbrake)
            Bugsnag.notify(exception, data: {payload: data, retries: retries}) if defined?(Bugsnag)
          rescue Interrupt => exception
            success = false
            logger.error "Interrupt in subscribe block"
            logger.warn "Stopped gracefully."
            throw(:terminate)
          ensure
            unless success
              reject_message(delivery_info.delivery_tag)
            end
          end
        end
      ensure
        logger.info "Closing Channel"
        channel.close
      end
    end

    private
    def ack_message(tag)
      logger.info "Acking message"
      channel.acknowledge(tag, false)
    end

    def reject_message(tag)
      logger.info "Rejecting message"
      channel.reject(tag, true)
    end

    def queue
      @queue ||= channel.queue(@consumer.class::QUEUE, @channel_opts)
    end

    def connection
      @connection ||= Bunny.new(@url).tap { |bunny| bunny.start }
    end

    def channel
      @channel ||= begin
        c = connection.create_channel
        c.prefetch(@prefetch)
        c
      end
    end

    def logger
      @logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
    end
  end
end
