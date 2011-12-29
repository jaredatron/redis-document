module Redis::Document

  module ClassMethods

    def contains_one klass, options = {}
      klass = klass.to_s.classify unless klass.is_a? Class
      name  = (options[:as] || klass).to_s.underscore
      # options[:as] ||= name
      # associations[name.to_sym] = Associations::ContainsOne.new(options)

      after_save{|document|
        document.send(name).save
      }

      class_eval <<-RUBY, __FILE__, __LINE__
        def #{name}
          @#{name} ||= begin
          end
        end

        def #{name}= document
          @#{name} = document
        end
      RUBY
    end

  end

end

# class Redis::Document::Associations::ContainsOne

#   def initialize options
#     @options = options
#   end
#   attr_reader :options

#   def for document
#     Struct.new(:VIDEOP).new
#   end

# end
