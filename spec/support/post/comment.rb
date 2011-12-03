class Post::Comment

  include Redis::Document::Namespace

  key :author
  key :body
  key :created_at

  def initialize post, id
    @post, @id = post, id
  end

  attr_reader :post, :id
  alias_method :document, :post


end
