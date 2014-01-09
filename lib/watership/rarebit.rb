module Watership
  class Rarebit
    def start; end

    def connected?
      false
    end

    def create_channel
      Watership::RarebitChannel.new
    end
  end
end