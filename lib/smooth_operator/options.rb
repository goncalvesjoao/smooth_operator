module SmoothOperator
  module Options

    def get_option(option, default, *args)
      return default unless config_options.include?(option)

      _option = config_options[option]

      case _option
      when Symbol
        respond_to?(_option) ? send(_option, *args) : _option
      when Proc
        _option.call(*args)
      else
        _option
      end
    end

    def config_options
      Helpers.get_instance_variable(self, :config_options, {})
    end

    def smooth_operator_options(options = {})
      config_options.merge!(options)
    end

    alias_method :options, :smooth_operator_options

  end
end
