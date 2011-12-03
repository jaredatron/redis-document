module Redis::Document

  module ClassMethods

    def has_one name, options={}
      name = name.to_sym
      associations[name] = HasOneAssociation.new(name, options)
      define_method(name){
        self.class.associations[name].for(self)
      }
    end
    alias_method :has_a, :has_one

  end

  class HasOneAssociation
    def initialize name, options
      @name, @options = name, options
    end
    attr_reader :name, :options

    def class
      @class ||= (options[:class] || name).to_s.classify.constantize
    end

    def prefix
      self.class.name
    end

    def for document
      Collection.new(self, document)
    end


    end

  end

end
