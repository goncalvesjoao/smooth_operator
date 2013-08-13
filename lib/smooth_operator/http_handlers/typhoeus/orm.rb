module SmoothOperator
  module HttpHandlers
    module Typhoeus

      class ORM

        attr_reader :object_class

        def initialize(object_class)
          @object_class = object_class
        end

        def make_the_call(http_verb, options, id, &block)
          injected_hydra = options[:hydra]
          options[:hydra] = injected_hydra || ::Typhoeus::Hydra::hydra
          
          binding.pry

          remote_call = @object_class.make_the_call(http_verb, id, options)

          remote_call.request.on_complete do |typhoeus_response|
            remote_call.raw_response = typhoeus_response
            yield(remote_call)
          end
          
          options[:hydra].run if injected_hydra.blank?

          remote_call
        end
        
      end

    end
  end
end
