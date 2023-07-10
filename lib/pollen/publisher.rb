module Pollen
  class Publisher
    class NotSetMessageError < StandardError; end

    def self.use_message(message_klass)
      @message_klass = message_klass
    end

    def self.message_klass
      @message_klass || nil
    end

    def self.publish!(message)
      raise NotSetMessageError, "No message class defined" unless message_klass
      message.validate!
      ActiveSupport::Notifications.instrument(message.class.topic_id, message: message.to_h)
    end
  end
end
