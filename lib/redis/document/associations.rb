module Redis::Document

  module ClassMethods

    def associations
      @associations ||= {}
    end

  end

  module Associations

  end

end

require 'redis/document/associations/contains_one'
# require 'redis/document/associations/contains_many'
# require 'redis/document/associations/knows_one'
# require 'redis/document/associations/knows_many'
