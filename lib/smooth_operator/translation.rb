module SmoothOperator

  module Translation

    def human_attribute_name(attribute_key_name, options = {})
      _translate("attributes.#{model_name.i18n_key}.#{attribute_key_name}", options = {})
    end


    private ###################### PRIVATE #########################

    def _translate(namespace = '', options = {})
      no_translation = "-- no translation --"
      
      defaults = ["smooth_operator.#{namespace}".to_sym]
      defaults << "activerecord.#{namespace}".to_sym
      defaults << options[:default] if options[:default]
      defaults.flatten!
      defaults << no_translation
      
      options = { count: 1, default: defaults }.merge!(options.except(:default))
      I18n.translate(defaults.shift, options)
    end

  end

end