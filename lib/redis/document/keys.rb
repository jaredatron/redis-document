module Redis::Document::Keys

  extend ActiveSupport::Concern

  module ClassMethods

    def keys
      @keys ||= []
      (superclass.respond_to?(:keys) ? superclass.keys : []) + @keys
    end

    def key name
      @keys ||= []
      return if @keys.include? name
      @keys << name
      class_eval <<-RUBY, __FILE__, __LINE__
        def #{name}
          read_key "#{name}"
        end
        def #{name}= value
          write_key "#{name}", value
        end
      RUBY
    end

  end

  module InstanceMethods

    def keys
      self.class.keys
    end

  end

end
