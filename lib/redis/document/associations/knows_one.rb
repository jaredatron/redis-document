module Redis::Document

  module ClassMethods

    def knows_one
    end

  end

end
    # def knows_one klass, options = {}
    #   klass = klass.to_s.classify unless klass.is_a? Class
    #   name  = (options[:as] || klass).to_s.underscore
    #   # options[:as] ||= name
    #   # associations[name.to_sym] = Associations::ContainsOne.new(options)

    #   class_eval <<-RUBY, __FILE__, __LINE__
    #     key "#{name}_id"

    #     def #{name}
    #       # @#{name} ||= self.class.associations[#{name.to_sym.inspect}].for(self)
    #       @#{name} ||= begin
    #         #{klass}.find(@#{name}_id) unless @#{name}_id.nil?
    #       end
    #     end

    #     def #{name}= document
    #       @#{name} = document
    #       @#{name}_id = document.id
    #     end
    #   RUBY
    # end
