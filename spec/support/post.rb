require 'redis/document'

class Post

  autoload :Comment, File.expand_path('../post/comment', __FILE__)

  include Redis::Document

  key :title
  key :body

end


class AwesomePost < Post

  key :animated_gif

end
