module Redis::Document

  module ClassMethods
    # embeds a subdocument using a redis namespace
    # - subdocuments dont needs IDS
    def knows_one class_name, options = {}
      class_name = class_name.to_s.classify unless class_name.is_a? Class
      name  = (options[:as] || class_name).to_s.underscore

      #TODO subclass Video changes its redis to be a namespace of the given document
      associations[name.to_sym] = Associations::KnowsOne.new(self, name, class_name)

      class_eval <<-RUBY, __FILE__, __LINE__
        key "#{name}_id"

        def #{name}
          @#{name} ||= begin
            id = send(:"#{name}_id") or return
            self.class.associations[#{name.to_sym.inspect}].class.find(id)
          end
        end

        def #{name}= document
          @#{name} = document
          send :#{name}_id=, document.id
        end

        before_save do
          # TODO worry about circular references
          if @#{name} && @#{name}.new_record?
            @#{name}.save
            self.#{name}= @#{name}
          end
        end

      RUBY
    end
  end

  class Associations::KnowsOne

    def initialize document, name, class_name
      @document, @name, @class_name = document, name, class_name
    end
    attr_reader :document, :name, :class_name

    def class
      @class ||= begin
        "#{document}::#{class_name}".constantize
      rescue NameError
        class_name.constantize
      end
    end

  end

end


    # ??? this is more like knows_one
    # def contains_one klass, options = {}
    #   klass = klass.to_s.classify unless klass.is_a? Class
    #   name  = (options[:as] || klass).to_s.underscore
    #   # options[:as] ||= name
    #   # associations[name.to_sym] = Associations::ContainsOne.new(options)

    #   class_eval <<-RUBY, __FILE__, __LINE__
    #     key "#{name}_id"

    #     def #{name}
    #       # @#{name} ||= self.class.associations[#{name.to_sym.inspect}].for(self)
    #       @#{name} ||= begin
    #         id = send(:#{name}_id)
    #         #{klass}.find(id) if id
    #       end
    #     end

    #     def #{name}= document
    #       @#{name} = document
    #       send :#{name}_id=,  document.id
    #     end
    #   RUBY
    # end
