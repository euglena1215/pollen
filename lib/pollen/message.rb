module Pollen
  class Message
    class AbstractClassError < StandardError; end
    class ValidationError < StandardError; end
    class InvalidTypeError < ValidationError; end;
    class RequiredError < ValidationError; end;

    TOPIC_PREFIX = "pollen"

    def self.topic_id
      # TODO: convert to snake case
      "#{TOPIC_PREFIX}.#{self.name}"
    end

    def self.attribute(name, type, options = {})
      @attributes ||= {}
      @attributes[name] = { type: type, options: options }

      self.class_eval do
        attr_accessor name
      end
    end

    def self.attributes
      @attributes || {}
    end

    def initialize(attrs = {})
      if self.class == Pollen::Message
        raise AbstractClassError, "Pollen::Message is an abstract class and cannot be instantiated."
      end

      self.class.attributes.each do |name, options|
        value = attrs[name]
        send("#{name}=", value)
      end

      super()
    end

    def validate!
      self.class.attributes.each do |name, options|
        value = send(name)
        type = options[:type]
        options = options[:options]

        validate_type!(name, value, type) unless value.nil?
        validate_options!(name, value, options)
      end
    end

    def to_h
      self.class.attributes.each_with_object({}) do |(name, _), hash|
        hash[name] = send(name)
      end
    end

    private

    def validate_type!(name, value, type)
      case type
      when :string
        raise InvalidTypeError, "#{name} must be a string" unless value.is_a?(String)
      when :integer
        raise InvalidTypeError, "#{name} must be an integer" unless value.is_a?(Integer)
      when :float
        raise InvalidTypeError, "#{name} must be a float" unless value.is_a?(Float)
      when :boolean
        raise InvalidTypeError, "#{name} must be a boolean" unless value.is_a?(TrueClass) || value.is_a?(FalseClass)
      when :array
        raise InvalidTypeError, "#{name} must be an array" unless value.is_a?(Array)
      when :hash
        raise InvalidTypeError, "#{name} must be a hash" unless value.is_a?(Hash)
      else
        raise InvalidTypeError, "#{name} has an invalid type"
      end
    end

    def validate_options!(name, value, options)
      if options[:required] && value.nil?
        raise RequiredError, "#{name} is required"
      end
    end
  end
end
