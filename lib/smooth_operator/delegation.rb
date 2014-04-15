module SmoothOperator

  module Delegation

    module MissingMethods

      def respond_to?(method)
        @internal_data.keys.include?(method.to_sym) ? true : super
      end

      def method_missing(method, *args, &block)
        if Helpers.setter_method?(method)
          @internal_data[method.to_s[0..-1]] = args.first
        else
          @internal_data.fetch(method, args.first)
        end
      end

    end

    def zuper_method(method_name, *args)
      self.superclass.send(method_name, *args) if self.superclass.respond_to?(method_name)
    end

  end

end
