require 'typhoeus'

module SmoothOperator
  module ProtocolHandlers
    
    class Typhoeus
  
      def self.get(url, options, basic_auth_credentials)
        hydra = get_hydra_and_remove_it_from options
        make_request_and_return_hydra_handler(url, hydra, get_options(options))
      end

      def self.post(url, options, basic_auth_credentials)
        hydra = get_hydra_and_remove_it_from options
        make_request_and_return_hydra_handler(url, hydra, post_options(options))
      end

      def self.put(url, options, basic_auth_credentials)
        hydra = get_hydra_and_remove_it_from options
        make_request_and_return_hydra_handler(url, hydra, put_options(options))
      end

      def self.delete(url, options, basic_auth_credentials)
        hydra = get_hydra_and_remove_it_from options
        make_request_and_return_hydra_handler(url, hydra, delete_options(options))
      end


      private ###################### PRIVATE ##############

      def self.get_options(options)
        options = { params: options, method: :get }
        options.merge! get_basic_auth_credentials(basic_auth_credentials)
      end

      def self.post_options(options)
        options = { body: options, method: :post }
        options.merge! get_basic_auth_credentials(basic_auth_credentials)
      end

      def self.put_options(options)
        options = { body: options, method: :put }
        options.merge! get_basic_auth_credentials(basic_auth_credentials)
      end

      def self.delete_options(options)
        options = { body: options, method: :delete }
        options.merge! get_basic_auth_credentials(basic_auth_credentials)
      end

      def self.get_basic_auth_credentials(basic_auth_credentials)        
        basic_auth_credentials.blank? ? {} : { userpwd: "#{basic_auth_credentials[:username]}:#{basic_auth_credentials[:password]}" }
      end
      
      def get_hydra_and_remove_it_from(options)
        options.delete(:hydra) || Typhoeus::Hydra.hydra
      end

      def make_request_and_return_hydra_handler(url, hydra, options)
        request = Typhoeus::Request.new(url, options)
        
        request.on_complete { |response| handle_response(response) }

        hydra.queue(request)

        hydra
      end

      def handle_response(response)
        if response.success?
          # hell yeah
        elsif response.timed_out?
          # aw hell no
          log("got a time out")
        elsif response.code == 0
          # Could not get an http response, something's wrong.
          log(response.return_message)
        else
          # Received a non-successful http response.
          log("HTTP request failed: " + response.code.to_s)
        end
      end

    end
    
  end
end
