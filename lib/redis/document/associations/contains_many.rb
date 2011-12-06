module Redis::Document

  module ClassMethods
    # embeds a subdocument using a redis namespace
    # - subdocuments dont needs IDS
    def contains_many class_name, options = {}
      class_name = class_name.to_s.classify unless class_name.is_a? Class
      name = (options[:as] || class_name).to_s.pluralize.underscore

      associations[name.to_sym] = Associations::ContainsMany.new(self, name, class_name)

      class_eval <<-RUBY, __FILE__, __LINE__
        def #{name}
          @#{name} ||= self.class.associations[#{name.to_sym.inspect}].collection_for(self)
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

  class Associations::ContainsMany


    def initialize document_class, name, class_name
      @document_class, @name, @class_name = document_class, name, class_name
    end
    attr_reader :document_class, :name, :class_name

    def class
      @class ||= begin
        "#{document_class}::#{class_name}".constantize
      rescue NameError
        class_name.constantize
      end
    end

    def collection_for document_instance
      Collection.new(self, document_instance)
    end

    class Collection
      instance_methods.each { |m| undef_method m unless m =~ /^__/ }

      def initialize association, document
        @association, @document = association, document
      end

      def method_missing method, *args, &bock
        documents.send method, *args, &bock
      end

      def documents
        @documents ||= redis.blank? ? [] :
          redis.keys.map{|key| key =~ /^(.*):id$/; $1 }.compact.map{|id| new_member(id) }
      end

      def new
        new_member
      end

      def redis
        if redis = @document.redis
          @redis = Redis::Namespace.new(@association.name, :redis => redis)
        end
      end

      private

      def new_member id=nil
        association_class.new.tap{|member|
          member.instance_variable_set(:@id, id) if id
          member.instance_variable_set(:@collection, self)
          @documents << member if @documents
        }
      end

      def association_class
        @association_class or begin
          @association_class = Class.new(@association.class){
            class << self
              delegate :name, :inspect, :to_s, :to => :superclass
              delegate :redis, :to => :@collection
            end
          }
          @association_class.instance_variable_set(:@collection, self)
        end
        @association_class
      end

    end

  end

end
