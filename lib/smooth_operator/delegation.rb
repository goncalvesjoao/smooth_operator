module SmoothOperator

  module Delegation

    module MissingMethods

      def respond_to?(method)
        known_attributes.include?(method.to_s) ? true : super
      end

      def method_missing(method, *args, &block)
        _method = method.to_s

        if Helpers.setter_method?(_method)
          return internal_data[_method[0..-1]] = args.first
        elsif respond_to?(_method)
          return internal_data[_method]
        end

        super
      end

    end

    def zuper_method(method_name, *args)
      self.superclass.send(method_name, *args) if self.superclass.respond_to?(method_name)
    end

  end

end
