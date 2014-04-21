module SmoothOperator

  module Naming

    def model_name
      if defined? ActiveModel
        rails_model_name_method
      else
        name.split('::').last.underscore.capitalize
      end
    end

    protected ############## PROTECTED #############

    def rails_model_name_method
      @_model_name ||= begin
        namespace = self.parents.detect do |n|
          n.respond_to?(:use_relative_model_naming?) && n.use_relative_model_naming?
        end
        ActiveModel::Name.new(self, namespace)
      end
    end

  end

end
