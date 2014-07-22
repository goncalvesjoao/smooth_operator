module SmoothOperator
  module ResourceName

    def resources_name
      get_option :resources_name, self.resource_name.pluralize
    end

    def resource_name
      get_option :resource_name, self.model_name.to_s.underscore
    end

    def model_name
      return '' if custom_model_name == :none

      if defined? ActiveModel
        smooth_model_name
      else
        custom_model_name ||= name.split('::').last.underscore.capitalize
      end
    end

    def model_name=(name)
      @custom_model_name = name
    end

    def custom_model_name
      Helpers.get_instance_variable(self, :custom_model_name, nil)
    end

    protected ############## PROTECTED #############

    def smooth_model_name
      @_model_name ||= begin
        namespace ||= self.parents.detect do |n|
          n.respond_to?(:use_relative_model_naming?) && n.use_relative_model_naming?
        end

        ActiveModel::Name.new(self, namespace, custom_model_name).tap do |model_name|
          def model_name.human(options = {}); SmoothOperator::Translation::HelperMethods.translate("models.#{i18n_key}", options); end
        end
      end
    end

  end

end
