require 'redis'
require 'redis-namespace'
require 'active_support'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'

class Redis::DataSet

  DELIMITER = ':'

  class << self
    def [] *args, &block
      new(*args, &block)
    end
  end

  def initialize namespace = nil, redis = Redis.current, parent = nil
    @namespace, @redis, @parent = namespace, redis, parent
    reload
  end

  attr_reader :namespace, :redis, :parent

  def keys
    to_hash.keys
  end

  def persisted
    @persisted.clone
  end

  def changed
    @changed.clone
  end

  def deleted
    @deleted.clone
  end

  def persisted?
    @persisted.present?
  end

  def dirty?
    @changed.present? || @deleted.present?
  end

  def save
    return false if to_hash.empty? || parent.present? && !parent.persisted?
    redis.multi{
      @changed.keys.each{ |key| set(key, @changed.delete(key)) }
      del(@deleted.shift) while @deleted.present?
    }
    true
  end

  def reload
    @persisted = {}
    @changed = {}
    @deleted = []
    load
  end

  def [] key
    key = to_key(key)
    @changed[key] || @persisted[key]
  end

  def []= key, value
    key = to_key(key)
    @changed[key] = value
  end

  def delete key
    key = to_key(key)
    @changed.delete(key)
    @persisted.delete(key)
    @deleted << key
  end

  def get key
    key = to_key(key)
    @persisted[key] = Marshal.load(redis.get(full_key(key)))
  end

  def set key, value
    key = to_key(key)
    redis.set(full_key(key), Marshal.dump(value))
    @persisted[key] = value
  end

  def del key
    key = to_key(key)
    redis.del(full_key(key))
    @persisted.delete(key)
    key
  end

  def to_hash
    @persisted.merge(@changed)
  end

  def inspect
    data = to_hash.map{|k,v| "#{k}:#{v.inspect}"}.join(' ')
    "#<#{self.class} #{namespace} #{data}>"
  end
  alias_method :to_s, :inspect

  def data_set name
    Redis::DataSet.new(name, redis, self)
  end

  def data_sets
    redis.keys.find_all{|key| key.include?(DELIMITER)}
  end

  private

  def persisted_keys
    redis.keys.find_all{|key| key.include?(DELIMITER)}
  end

  def petsisted_data_sets
  end

  def all_keys
    redis.keys.map{|key| key =~ /^#{full_namespace}:(.+)$/; $1 }.compact
  end

  def data_set_keys
  end

  def load
    keys = all_keys.find_all{|key| !key.include?(DELIMITER)}
    values = redis.multi{ keys.each{ |key| redis.get(full_key(key)) } }
    keys.zip(values).each{|key, value|
      @persisted[key] = Marshal.load(value) unless value.nil?
    }
  end

  InvalidKey = Class.new(ArgumentError)
  def to_key key
    key = key.to_s
    raise InvalidKey, key if key =~ /^$|:/
    key
  end

  def full_namespace
    [parent.try(:full_namespace), namespace].compact.join(':')
  end

  def full_key key
    [full_namespace, key].compact.join(':')
  end

end

class Redis

  def data_set namespace
    DataSet.new(namespace, self)
  end

end
