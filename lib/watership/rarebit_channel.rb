module Watership
  class RarebitChannel < Hash
    def queue(*args)
      self[args.first] = RarebitQueue.new
    end
  end
end