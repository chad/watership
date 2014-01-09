module Watership
  class Rarebit
    def start; end

    def connected?
      false
    end

    def create_channel
      RarebitChannel.new
    end
  end
end