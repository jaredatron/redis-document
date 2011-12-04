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

  autoload :ClassMethods,    'redis/document/class_methods'
  autoload :InstanceMethods, 'redis/document/instance_methods'
  autoload :Associations,    'redis/document/associations'

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

end

# require 'redis/document/has_one'
# require 'redis/document/has_many'
