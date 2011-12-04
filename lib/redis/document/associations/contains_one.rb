class Redis::Document::Associations::ContainsOne

  def initialize options
    @options = options
  end
  attr_reader :options

  def for document
    Struct.new(:VIDEOP).new
  end

end
