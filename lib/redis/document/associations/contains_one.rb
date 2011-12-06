module Redis::Document

  module ClassMethods
    # embeds a subdocument using a redis namespace
    # - subdocuments dont needs IDS
    def contains_one class_name, options = {}
      class_name = class_name.to_s.classify
      name  = (options[:as] || class_name).to_s.underscore

      class_eval <<-RUBY, __FILE__, __LINE__
        def self.#{name}_class
          @#{name}_class ||= Class.new(#{class_name}).tap{|klass|
            klass.send(:include, Associations::ContainsOne)
          }
        end

        def #{name}
          parent_document = self
          @#{name} ||= self.class.#{name}_class.new.tap{|instance|
            instance.instance_variable_set(:@parent_document, self)
            instance.instance_variable_set(:@association_name, "#{name}")
          }
        end

        after_save do
          self.#{name}.save
        end

      RUBY
    end
  end

  module Associations::ContainsOne
    def redis
      if redis = @parent_document.send(:redis)
        @redis = Redis::Namespace.new(@association_name, :redis => redis)
      end
    end

  end

end
