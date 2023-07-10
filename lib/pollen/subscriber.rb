module Pollen
  class Subscriber
    class AbstractClassError < StandardError; end
    class NotSetMessageError < StandardError; end
    def self.use_message(message_klass)
      @message_klass = message_klass
    end

    def self.message_klass
      @message_klass || nil
    end

    def self.subscribe!(_message)
      raise NotImplementedError, "Implement me in a subclass"
    end

    def self.listen!
      raise NotSetMessageError, "No message class defined" unless self.message_klass
      return if is_listening?

      ActiveSupport::Notifications.subscribe(message_klass.topic_id) do |_name, _started, _finished, _unique_id, payload|
        message = self.message_klass.new(payload[:message])
        subscribe!(message)
      end
      @is_listening = true
    end

    def self.is_listening?
      defined?(@is_listening) ? @is_listening : false
    end
  end
end
