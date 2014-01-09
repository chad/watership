module Watership
  class RarebitQueue < Array
    def publish(payload)
      self << payload
    end

    def pop
      payload = super
      return nil, {}, payload
    end
  end
end