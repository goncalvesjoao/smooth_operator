module SmoothOperator

  module Delegation

    module MissingMethods

      def respond_to?(method)
        known_attributes.include?(method.to_s) ? true : super
      end

      def method_missing(method, *args, &block)
        if Helpers.setter_method?(method)
          internal_data[method.to_s[0..-1]] = args.first
        else
          internal_data[method.to_s]
        end
      end

    end

    def zuper_method(method_name, *args)
      self.superclass.send(method_name, *args) if self.superclass.respond_to?(method_name)
    end

  end

end
