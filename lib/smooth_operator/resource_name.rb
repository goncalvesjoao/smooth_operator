module SmoothOperator
  module ResourceName

    def resources_name(default_bypass = nil)
      return @resources_name if defined?(@resources_name)

      (Helpers.super_method(self, :resources_name, true) || (default_bypass ? nil : self.resource_name.pluralize))
    end

    attr_writer :resources_name

    def resource_name(default_bypass = nil)
      return @resource_name if defined?(@resource_name)

      (Helpers.super_method(self, :resource_name, true) || (default_bypass ? nil : self.model_name.to_s.underscore))
    end

    attr_writer :resource_name

    def model_name
      return '' if @_model_name == :none

      if defined? ActiveModel
        rails_model_name_method
      else
        @_model_name ||= name.split('::').last.underscore.capitalize
      end
    end

    def model_name=(name)
      @_model_name = name
    end

    protected ############## PROTECTED #############

    def rails_model_name_method
      @model_name ||= begin
        namespace ||= self.parents.detect do |n|
          n.respond_to?(:use_relative_model_naming?) && n.use_relative_model_naming?
        end

        ActiveModel::Name.new(self, namespace, @_model_name).tap do |model_name|
          def model_name.human(options = {}); SmoothOperator::Translation::HelperMethods.translate("models.#{i18n_key}", options); end
        end
      end
    end

  end

end
