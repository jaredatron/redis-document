module Redis::Document::Namespace

  extend ActiveSupport::Concern

  included do
    include Redis::Document::Keys
  end

  module ClassMethods

  end

  module InstanceMethods

    attr_reader :document, :prefix, :index

    def write_key key, value
      document.write_key("#{prefix}:#{index}:#{key}", value)
      true
    end

    def read_key key
      document.read_key("#{prefix}:#{index}:#{key}")
    end

    def inspect
      content = ["index: #{index}"] + keys.map{|key| "#{key}: #{read_key(key).inspect}"}
      "#<#{self.class} #{content.join(', ')}>"
    end
    alias_method :to_s, :inspect

  end

end
