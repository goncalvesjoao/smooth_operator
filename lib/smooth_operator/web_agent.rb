module SmoothOperator

  module WebAgent

    HTTP_VERBS = [:get, :post, :put, :delete]

    OPTIONS = [:endpoint, :endpoint_user, :endpoint_pass, :timeout]


    def self.extended(base)
      base.class_eval do
        attr_writer *OPTIONS

        OPTIONS.each do |option| define_method(option) { get_option(option) } }

        HTTP_VERBS.each { |http_verb| define_http_verb_method http_verb }
      end
    end
    

    def generate_parallel_connection
      generate_connection(:typhoeus)
    end

    def generate_connection(adapter = :net_http)
      Faraday.new(url: endpoint) do |faraday|
        faraday.request  :url_encoded
        faraday.adapter  adapter
      end
    end


    protected ################ PROTECTED ################

    def make_the_call(http_verb, relative_path, params = {}, options = {})
      connection, options = strip_options(options)

      response = connection.send(http_verb) do |request|
        request.params params
        request.url relative_path
        options.each { |key, value| request.options.send("#{key}=", value) }
      end

      # RemoteCall.new(response)
      response
    end


    private ################# PRIVATE ###################

    def strip_options(options)
      options ||= {}

      options[:timeout] ||= timeout
      connection = (options.delete(:connection) || generate_connection)

      [connection, options]
    end

    def get_option(option)
      instance_var = instance_variable_get("@#{option}")

      return instance_var unless instance_var.nil?

      (zuper_method(option) || ENV["API_#{option.upcase}"]).dup.tap do |instance_var|
        instance_variable_set("@#{option}", instance_var)
      end
    end

    def define_http_verb_method(http_verb)
      define_method(http_verb) do |relative_path = '', params = {}, options = {}|
        make_the_call(http_verb, relative_path, params, options)
      end
    end

  end

end
