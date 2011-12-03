class Post::Comment

  include Redis::Document::Namespace

  document :is => :@post

  def initialize post
    @post = post
  end

end
