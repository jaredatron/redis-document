require 'redis/document'

class Post

  include Redis::Document

  key :title
  key :body

end


class AwesomePost < Post

  key :animated_gif

end
