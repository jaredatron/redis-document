module Redis::Document

  module ClassMethods
    def contains_many class_name, options = {}
      class_name = class_name.to_s.classify unless class_name.is_a? Class
      name = (options[:as] || class_name).to_s.pluralize.underscore

      class_eval <<-RUBY, __FILE__, __LINE__
        def #{name}
          @#{name} ||= Redis::Document::Associations::ContainsMany::Collection.new(self, "#{name}", #{class_name})
        end

        def #{name}= document
          @#{name} = document
          send :#{name}_id=, document.id
        end

        after_save do
          #{name}.each(&:save)
        end
      RUBY
    end
  end

  module Associations::ContainsMany

    class Collection
      instance_methods.each { |m| undef_method m unless m =~ /^__/ }

      def initialize document, name, klass
        @document, @name, @class = document, name, klass
      end

      def method_missing method, *args, &bock
        documents.send method, *args, &bock
      end

      def documents
        @documents ||= redis.blank? ? [] :
          redis.keys.map{|key| key =~ /^(.*):id$/; $1 }.compact.map{|id| new_member(id) }
      end

      def new *args, &block
        new_member(nil, *args, &block)
      end

      def redis
        if redis = @document.redis
          @redis = Redis::Namespace.new(@name, :redis => redis)
        end
      end

      private

      def new_member id=nil, *args, &block
        association_class.new(*args, &block).tap{|member|
          member.instance_variable_set(:@id, id) if id
          member.instance_variable_set(:@collection, self)
          @documents << member if @documents
        }
      end

      def association_class
        @association_class or begin
          @association_class = Class.new(@class){
            class << self
              delegate :name, :inspect, :to_s, :to => :superclass
              delegate :redis, :to => :@collection
            end
            # def self.redis
            #   @collection.redis
            # end
            def class
              super #.superclass
            end
          }
          @association_class.instance_variable_set(:@collection, self)
        end
        @association_class
      end

    end

  end

end