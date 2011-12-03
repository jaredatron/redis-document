require 'redis'
require 'redis/namespace'
require 'redis/document/version'
require 'uuid'

require 'active_support'
require 'active_support/core_ext/array'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/try'
require 'active_support/inflections'
require 'active_support/concern'
require 'active_support/buffered_logger'
require 'active_support/core_ext/benchmark'

require 'active_model'

module Redis::Document

  autoload :Keys,      'redis/document/keys'
  autoload :Namespace, 'redis/document/namespace'

  extend ActiveSupport::Concern

  class << self

    def redis
      @redis or self.redis = ::Redis.current and @redis
    end
    attr_writer :redis

    def logger= logger
      @logger = logger.respond_to?(:info) ? logger : ActiveSupport::BufferedLogger.new(logger)
    end

    def logger
      @logger or self.logger = STDOUT and @logger
    end

    def associations
      @associations ||= {}
    end

  end

  included do
    # include Redis::Document::Keys
    extend ActiveModel::Callbacks
    define_model_callbacks :save, :delete
  end

  module ClassMethods

    def redis= redis
      @redis = Redis::Namespace.new(name, :redis => redis)
    end

    def redis
      @redis or self.redis = Redis::Document.redis and @redis
    end

    def find id
      benchmark(:find, id){
        document = new
        document.instance_variable_set(:@id, id)
        document.new_record? ? nil : document
      }
    end

    def all
      redis.keys.map{ |id| find id }
    end

    def benchmark action, id=nil
      name = id.nil? ? self.name : "#{self.name}(#{id})"
      result = nil
      ms = Benchmark.ms { result = yield }
      Redis::Document.logger.info('%s %s (%.1fms)' % [ name, action, ms ])
      result
    end

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

    def id
      @id ||= begin
        @new_record = true
        UUID.generate
      end
    end

    def write_key key, value
      key = key.to_s
      return false if _data_[key] == value
      _data_[key] = value
      _set_(key, Marshal.dump(value))
      @new_record = false
      true
    end

    def read_key key
      _data_[key.to_s]
    end

    def delete_key key
      _delete_ key.to_s
      _data_.delete(key.to_s)
      @new_record = _data_.keys.length == 0
    end

    def new_record?
      @new_record = !_exists_ if @new_record.nil?
      @new_record
    end
    alias_method :exists?, :new_record?

    def inspect
      content = ["id: #{id}"] + keys.map{|key| "#{key}: #{read_key(key).inspect}"}
      "#<#{self.class} #{content.join(', ')}>"
    end
    alias_method :to_s, :inspect

    def reload
      @_data_ = nil or _data_ and self
    end

    def destroy
      @_data_ = nil
      @new_record = true
      _destroy_
    end

    def benchmark action, &block
      self.class.benchmark(action, id, &block)
    end

    protected

    def _data_
      @_data_ ||= _load_.inject({}){ |_data_,(field,value)|
        _data_.update field => Marshal.load(value)
      }
    end

    def _exists_
      benchmark(:exists?){ self.class.redis.exists(id) }
    end

    def _load_
      return {} if id.nil? || @new_record == true
      benchmark(:load){ self.class.redis.hgetall(id) }
    end

    def _set_ key, value
      benchmark("write :#{key}"){ self.class.redis.hset(id, key, value) }
    end

    def _delete_ key
      benchmark("delete :#{key}"){ self.class.redis.hdel(id, key) }
    end

    def _destroy_
      benchmark(:exists?){ self.class.redis.del(id) }
    end

  end

end

require 'redis/document/has_one'
require 'redis/document/has_many'
