require 'redis/document'

class Post

  include Redis::Document

  contains_one  :video
  # knows_one     :user,    :as => :author
  # knows_many    :users,   :as => :fans
  # contains_many :comments

  key :title
  key :body
  key :created_at

end

class Video

  include Redis::Document

  key :url

end

# class Comment

#   include Redis::Document::Namespace

#   has_one :user, :as => :author

#   key :body
#   key :created_at

# end

# class User

#   include Redis::Document::Namespace

#   key :name
#   key :age

# end


class AwesomePost < Post

  key :animated_gif

end
