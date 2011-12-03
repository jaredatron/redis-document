require 'active_support/core_ext/benchmark'

class Redis::Document::Logger

  def initialize document, redis
    @document, @redis = document, redis
  end

  def respond_to?(*args)
    super or @redis.respond_to?(*args)
  end

  def method_missing method, *args, &block
    result = nil
    ms = Benchmark.ms { result = @redis.send(method, *args, &block) }
    @document.logger.info('%s (%.1fms)' % [ method, ms ])
    result
  end

end
