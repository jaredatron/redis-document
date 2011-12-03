require 'redis/document'

class Post

  autoload :Comment, File.expand_path('../post/comment', __FILE__)

  include Redis::Document

  key :title
  key :body
  key :created_at

  def comments
    (0..3).map{|index| Comment.new(self, index) }
  end

end


class AwesomePost < Post

  key :animated_gif

end
