module Redis::Document::Associations

  autoload :ContainsOne,  'redis/document/associations/contains_one'
  autoload :ContainsMany, 'redis/document/associations/contains_many'
  autoload :KnowsOne,     'redis/document/associations/knows_one'
  autoload :KnowsMany,    'redis/document/associations/knows_many'

end
