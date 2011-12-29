module Redis::Document
  module ClassMethods

    def redis= redis
      @redis = Redis::Namespace.new(name, :redis => redis)
    end

    def redis
      @redis or self.redis = Redis::Document.redis and @redis
    end

    def find id
      id = id.id if id.respond_to?(:id) && id.method(:id).owner != Kernel
      return nil if id.nil?
      benchmark(:find, id){
        document = new
        document.send(:load, id)
        document.new_record? ? nil : document
      }
    end

    def all
      redis.keys.map{ |id| find id }
    end

    def benchmark action, id=nil
      result = nil
      ms = Benchmark.ms { result = yield }
      Redis::Document.logger.info('%s %s (%.1fms) %s' % [ name, action, ms, id ])
      result
    end

    def keys
      @keys ||= []
      (superclass.respond_to?(:keys) ? superclass.keys : []) + @keys
    end

    def key key
      key = key.to_sym
      @keys ||= []
      return if @keys.include? key
      @keys << key
      attr_accessor key
    end

    def associations
      @associations ||= {}
    end

  end
end
