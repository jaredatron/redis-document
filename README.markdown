Post::96a0ea9013f1012f96461c6f65c57b04::created_at
Post::96a0ea9013f1012f96461c6f65c57b04::title
Post::96a0ea9013f1012f96461c6f65c57b04::body
Post::96a0ea9013f1012f96461c6f65c57b04::Comment::b23b894013f1012f96461c6f65c57b04::author::name
Post::96a0ea9013f1012f96461c6f65c57b04::Comment::b23b894013f1012f96461c6f65c57b04::author::email
Post::96a0ea9013f1012f96461c6f65c57b04::Comment::b23b894013f1012f96461c6f65c57b04::content


Redis::DataSet
  - redis namespace
  - has_many keys
  - has_many subsets


Post id:96a0ea9013f1012f96461c6f65c57b04
 - redis namespace : "Post::96a0ea9013f1012f96461c6f65c57b04"
 - keys
   - created_at
   - title
   - body
- subsets
  - Comment id:b23b894013f1012f96461c6f65c57b04
    - redis namespace : "Comment::b23b894013f1012f96461c6f65c57b04"
    - keys
      - content
    - subsets
      - Author

