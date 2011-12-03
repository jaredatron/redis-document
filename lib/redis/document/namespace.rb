module Redis::Document::Namespace

  extend ActiveSupport::Concern

  module ClassMethods

    def document options
      is = options.delete(:is)
      if is.to_s =~ /^@/
        define_method(:document){ instance_variable_get(is) }
      else
        define_method(:document){ send(is) }
      end
    end

  end

end
