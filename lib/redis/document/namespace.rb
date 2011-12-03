module Redis::Document::Namespace

  extend ActiveSupport::Concern

  included do
    include Redis::Document::Keys
  end

  module ClassMethods

  end

  module InstanceMethods

    def initialize document, id
      @document, @id = document, id
    end
    attr_reader :document, :id

    def write_key key, value
      document.write_key("#{self.class.name}:#{id}:#{key}", value)
      true
    end

    def read_key key
      document.read_key("#{self.class.name}:#{id}:#{key}")
    end

  end

end
