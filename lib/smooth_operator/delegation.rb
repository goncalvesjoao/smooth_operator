module SmoothOperator

  module Delegation

    def respond_to?(method)
      known_attributes.include?(method.to_s) ? true : super
    end

    def method_missing(method, *args, &block)
      _method = method.to_s

      if Helpers.setter_method?(_method)
        return push_to_internal_data(_method[0..-2], args.first)
      elsif respond_to?(_method)
        return get_internal_data(_method)
      end

      super
    end

  end

end
