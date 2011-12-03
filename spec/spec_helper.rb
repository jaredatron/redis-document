require 'redis/document'

SPEC_ROOT = Pathname.new(File.expand_path('..', __FILE__))
SPEC_ROOT.join('support').children.each{ |support| require support.to_s }

RSpec.configure do |config|

  config.color_enabled = true

  config.before :each do
    @log = StringIO.new
    Redis::Document.logger = @log
    Redis.current.client.db = 10
    Redis.current.flushdb
  end

  config.include(Module.new{
    def log
      @log.string ||= ""
    end

    def log_lines
      log.split("\n")
    end

    def empty_log!
      @log.string = ""
    end
  })

end
