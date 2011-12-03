module Factory

  extend self

  def document name = 'ExampleRedisDocument'
    named_anonymous_class(name) do
      include Redis::Document
    end
  end

  def namespace name = 'ExampleRedisDocumentNamespace'
    named_anonymous_class(name) do
      include Redis::Document::Namespace
    end
  end

  def named_anonymous_class name, &block
    name_proc = proc { name }
    klass = Class.new
    meta_klass = class << klass; self; end
    meta_klass.send(:define_method, :name,    &name_proc)
    meta_klass.send(:define_method, :inspect, &name_proc)
    meta_klass.send(:define_method, :to_s,    &name_proc)
    klass.class_eval(&block)
    klass
  end

end
