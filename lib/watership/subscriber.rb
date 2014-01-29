module Watership
  module Subscriber
    def perform(payload)
      raise NotImplementedError
    end

    def subscribe(name, options = {})
      options = { block: true, ack: true }.merge(options)

      queue(name).subscribe(options) do |delivery_info, properties, payload|
        perform(JSON.parse(payload))
        queue_channel.acknowledge(delivery_info.delivery_tag, false)
      end
    end

    protected

    def queue(name)
      Watership.connect_with_queue(name)
    end

    def queue_channel
      Watership.channel
    end
  end
end
