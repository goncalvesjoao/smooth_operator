module SmoothOperator
  module HttpHandlers
    module Typhoeus

      class ORM

        attr_reader :object_class

        def initialize(object_class)
          @object_class = object_class
        end

        def find_each(options, &block)
          make_the_call(:get, options, '') do |remote_call|
            yield(remote_call)
          end
        end

        def find_one(id, options, &block)
          make_the_call(:get, options, id) do |remote_call|
            yield(remote_call)
          end
        end

        def create(options, &block)
          make_the_call(:post, options, '') do |remote_call|
            yield(remote_call)
          end
        end

        def update(id, options, &block)
          make_the_call(:put, options, id) do |remote_call|
            yield(remote_call)
          end
        end

        def destroy(id, options, &block)
          make_the_call(:delete, options, id) do |remote_call|
            yield(remote_call)
          end
        end

        # THIS SHOULD NOT BE HERE!
        def rollback(id, options, &block)
          make_the_call(:delete, options, id) do |remote_call|
            yield(remote_call)
          end
        end

        private ############################# private ############################

        def make_the_call(http_verb, options, id, &block)
          injected_hydra = options[:hydra]
          options[:hydra] = injected_hydra || ::Typhoeus::Hydra.hydra

          remote_call = @object_class.make_the_call(http_verb, id, options)

          remote_call.request.on_complete do |typhoeus_response|
            remote_call.raw_response = typhoeus_response
            yield(remote_call)
          end
          
          remote_call.request.run if injected_hydra.blank?

          remote_call
        end
        
      end

    end
  end
end
