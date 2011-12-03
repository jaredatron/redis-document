require 'redis/document'

RSpec.configure do |config|

  config.color_enabled = true

  config.before :each do
    Redis::Document.instance_variables.each{|i| Redis::Document.send :remove_instance_variable, i }
    Redis.new.flushall
  end

end
