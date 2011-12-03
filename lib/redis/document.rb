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

  # autoload :Keys,      'redis/document/keys'
  # autoload :Namespace, 'redis/document/namespace'

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
    key :id
    # include Redis::Document::Keys
    extend ActiveModel::Callbacks
    define_model_callbacks :create, :find, :save, :delete
  end

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

  end

  module InstanceMethods

    InvalidKey = Class.new(StandardError)

    def keys
      self.class.keys
    end

    def set_key key, value
      raise InvalidKey unless keys.include? key.to_sym
      instance_variable_set(:"@#{key}", value)
    end

    def get_key key
      raise InvalidKey unless keys.include? key.to_sym
      instance_variable_get(:"@#{key}")
    end

    def set_key! key, value=get_key(key)
      set_key key, value
      @original_values ||= {}
      @original_values[key.to_sym] = value
      redis.set(key, Marshal.dump(value))
      value
    end

    def get_key! key
      value = Marshal.load(redis.get(key))
      set_key key, value
      @original_values ||= {}
      @original_values[key.to_sym] = value
      value
    end

    def values
      keys.inject({}){ |values, key| values[key] = get_key(key); values }
    end

    def original_values
      @original_values or keys.inject({}){ |values, key| values[key] = nil; values }
    end

    def new_record?
      @id.nil? || @original_values.nil? || @original_values.values.compact.length == 0
    end

    def save
      self.id ||= UUID.generate
      benchmark(:save){
        redis.multi{ keys.each{ |key| set_key! key } }
      }
      self
    end

    def reload
      load
    end

    def destroy
      redis.multi{ keys.each{ |key| redis.del(key) } }
      @original_values = {}
      @id = nil
      self
    end

    def benchmark action, &block
      self.class.benchmark(action, id, &block)
    end

    def inspect
      content = ([:id] + keys).map{|key| "#{key}: #{send(key).inspect}"}
      "#<#{self.class} #{content.join(', ')}>"
    end
    alias_method :to_s, :inspect

    private

    def redis
      @redis = Redis::Namespace.new(id, :redis => self.class.redis)
    end

    def load id = self.id
      return if id.nil?
      self.id = id
      benchmark(:load){
        @original_values ||= {}
        values = redis.multi{ keys.each{ |key| redis.get(key) } }
        keys.zip(values).each{|key, value|
          value = Marshal.load(value) unless value.nil?
          @original_values[key] = value
          set_key(key, value)
        }
      }
      self
    end


    # # def id
    # #   @id ||= UUID.generate
    # # end

    # # def set_key key, value
    # #   @values["#{key}"] = value
    # #   __set__ key, value
    # # end

    # # def get_key key
    # #   __get__ key, value
    # # end

    # def new_record?
    #   @new_record = !_exists_ if @new_record.nil?
    #   @new_record
    # end
    # alias_method :exists?, :new_record?

    # def reload
    #   @_data_ = nil or _data_ and self
    # end

    # def destroy
    #   @_data_ = nil
    #   @new_record = true
    #   _destroy_
    # end

    # def benchmark action, &block
    #   self.class.benchmark(action, id, &block)
    # end

    # def inspect
    #   content = ["id: #{id}"] + keys.map{|key| "#{key}: #{read_key(key).inspect}"}
    #   "#<#{self.class} #{content.join(', ')}>"
    # end
    # alias_method :to_s, :inspect

    # protected

    # def _redis_
    #   @redis = Redis::Namespace.new(id, :redis => self.class.redis)
    # end

    # def _cache_
    #   @_cache_ ||= {}
    #   # _load_.inject({}){ |_data_,(field,value)|
    #     # _data_.update field => Marshal.load(value)
    #   # }
    # end

    # def _exists_
    #   benchmark(:exists?){ redis.keys.length > 0 }
    # end

    # def _set_ key, value
    #   benchmark("write :#{key}"){ _redis_.set(key, value) }
    # end

    # def _get_ key
    #   benchmark("read :#{key}"){ _redis_.get(key) }
    # end

    # def _destroy_
    #   benchmark(:destroy){ _redis_.keys.each{ |key| _redis_.del(key) } }
    # end





    # # def _exists_
    # #   benchmark(:exists?){ self.class.redis.exists(id) }
    # # end

    # # def _load_
    # #   return {} if id.nil? || @new_record == true
    # #   benchmark(:load){ self.class.redis.hgetall(id) }
    # # end

    # # def _set_ key, value
    # #   benchmark("write :#{key}"){ self.class.redis.hset(id, key, value) }
    # # end

    # # def _delete_ key
    # #   benchmark("delete :#{key}"){ self.class.redis.hdel(id, key) }
    # # end

    # # def _destroy_
    # #   benchmark(:exists?){ self.class.redis.del(id) }
    # # end

  end

end

require 'redis/document/has_one'
require 'redis/document/has_many'
