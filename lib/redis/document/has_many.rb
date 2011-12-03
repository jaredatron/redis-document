module Redis::Document

  module ClassMethods

    attr_reader :associations

    def has_many name, options={}
      name = name.to_sym
      associations[name] = HasManyAssociation.new(name, options)
      define_method(name){
        self.class.associations[name].collection_for(self)
      }
    end

  end

  class HasManyAssociation
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

    def collection_for document
      Collection.new(self, document)
    end

    class Collection

      include Enumerable

      def initialize association, document
        @association, @document = association, document
      end
      attr_reader :association, :document

      def each &block
        members.each(&block)
      end

      def inspect
        "#<#{document.class.name}##{association.name} #{members.inspect}>"
      end

      def new *args, &block
        new_member size, *args, &block
      end

      private

      delegate :size, :length, :count, :[], :to => :members
      def members
        @members or begin
          @members = []
          document.send(:_data_).keys \
            .map{|key| key =~ /^Comment:(\d+):/ ? $1.to_i : nil } \
            .compact.uniq.sort \
            .each{|index| new_member(index) }
        end
        @members
      end

      def new_member index, *args, &block
        member = association.class.new(*args, &block)
        member.instance_variable_set(:@document, document)
        member.instance_variable_set(:@prefix,   association.prefix)
        member.instance_variable_set(:@index,    index)
        members[index] = member
      end

    end

  end

end
