module Pollen
  class Subscriber
    def self.use_message(message_klass)
      @message_klass = message_klass
    end

    def self.message_klass
      @message_klass || nil
    end

    def self.subscribe(message)
      raise "No message class defined" unless message_klass
      # TODO: Subscribe from queue
    end
  end
end
