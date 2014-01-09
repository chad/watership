module Watership
  class RarebitChannel < Hash
    def queue(*args)
      self[args.first] = Watership::RarebitQueue.new
    end
  end
end