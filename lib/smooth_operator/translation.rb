module SmoothOperator

  module Translation

    def human_attribute_name(attribute_key_name, options = {})
      no_translation = "-- no translation --"
      
      defaults = ["smooth_operator.attributes.#{model_name.i18n_key}.#{attribute_key_name}".to_sym]
      defaults << "activerecord.attributes.#{model_name.i18n_key}.#{attribute_key_name}".to_sym
      defaults << options[:default] if options[:default]
      defaults.flatten!
      defaults << no_translation
      options[:count] ||= 1
      
      I18n.translate(defaults.shift, options.merge(default: defaults))
    end

  end

end