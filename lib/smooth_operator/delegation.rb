module SmoothOperator
  module Delegation

    def respond_to?(method, include_private = false)
      known_attribute?(method) ? true : super
    end

    def method_missing(method, *args, &block)
      method_name = method.to_s

      if !! ((method.to_s) =~ /=$/) #setter method
        internal_data_push(method_name[0..-2], args.first)
      elsif !self.class.strict_behaviour || known_attribute?(method_name)
        internal_data_get(method_name)
      else
        super
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def strict_behaviour
        Helpers.get_instance_variable(self, :strict_behaviour, false)
      end

      attr_writer :strict_behaviour

    end

  end
end
