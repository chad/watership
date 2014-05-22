require "json"

module Watership
  class Consumer
    def initialize(consumer, url, channel_options = {}, queue_options = {})
      @consumer = consumer
      @url = url
      @prefetch = channel_options.delete(:prefetch) || 0
      @channel_opts = {durable: true}.merge(channel_options)
      @queue_opts = {block: true, ack: true}.merge(queue_options)
    end

    def consume
      Thread.abort_on_exception = true
      begin
        queue.subscribe(@queue_opts) do |delivery_info, properties, payload|
          success = false
          begin
            @consumer.call(JSON.parse(payload))
            success = true
          rescue StandardError => exception
            Rails.logger.error "Error thrown in subscribe block"
            Rails.logger.error exception.message
            Rails.logger.error exception.backtrace.join("\n")
            Airbrake.notify(exception) if defined? AirBrake
            Rails.logger.info "Rejecting in rabbit"
            throw(:terminate)
          rescue Interrupt => exception
            Rails.logger.error "Interrupt in subscribe block"
            Rails.logger.warn "Stopped gracefully."
            throw(:terminate)
          ensure
            if success
              Rails.logger.info "Acking message"
              channel.acknowledge(delivery_info.delivery_tag, false)
            else
              Rails.logger.info "Rejecting message"
              channel.reject(delivery_info.delivery_tag, true)
            end
          end
        end
      ensure
        Rails.logger.info "Closing Channel"
        channel.close
      end
    end

    private

    def queue
      @queue ||= channel.queue(@consumer.class::QUEUE, @channel_options)
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
  end
end