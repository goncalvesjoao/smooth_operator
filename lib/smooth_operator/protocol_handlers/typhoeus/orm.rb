module SmoothOperator
  module ProtocolHandlers
    module Typhoeus

      class ORM

        def self.find_each(options, caller_class)
          find nil, options, caller_class do |remote_call|
            remote_call.response = return_array_of_objects_or_response(remote_call.parsed_response, caller_class)
          end
        end

        def self.find_one(id, options, caller_class)
          find id, options, caller_class do |remote_call|
            remote_call.response = caller_class.new(response.parsed_response)
          end
        end

        def self.save!(object, caller_class)
          object.send("last_response=", create_or_update(object, caller_class))

          object.assign_attributes(parse_response(object.last_response))

          if !caller_class.protocol_handler_base.successful_response?(object.last_response)
            SmoothOperator::Exceptions.raise_proper_exception(object.last_response, object.last_response.code)
          end

          true
        end

        def self.destroy(object, caller_class)
          return true if object.new_record?
          
          object.send("last_response=", caller_class.delete(object.id))
          
          object.assign_attributes(parse_response(object.last_response))

          caller_class.protocol_handler_base.successful_response?(object.last_response)
        end

        private #-------------------------------------- private

        def self.find(id, options, caller_class, &block)
          returning_response = nil

          injected_hydra = options[:hydra]
          options[:hydra] = injected_hydra || ::Typhoeus::Hydra.hydra

          remote_call = caller_class.get(id, options)

          remote_call.request.on_complete do |typhoeus_response|
            remote_call.raw_response = typhoeus_response
            yield(remote_call)
          end

          if injected_hydra.blank?
            remote_call.request.run
            remote_call.response
          else
            remote_call
          end
        end

        def self.parse_response(response)
          response.blank? ? nil : ::HTTParty::Parser.call(response.body, :json)
        end

        def self.parse_response_or_raise_proper_exception(response, caller_class)
          if caller_class.protocol_handler_base.successful_response?(response)
            parse_response(response)
          else
            SmoothOperator::Exceptions.raise_proper_exception(response, response.code)
          end
        end

        def self.return_array_of_objects_or_response(parsed_response, class_to_be_instantiated)
          if parsed_response.kind_of?(Array)
            parsed_response.map { |attributes| class_to_be_instantiated.new(attributes) }
          else
            parsed_response
          end
        end

        def self.create_or_update(object, caller_class)
          if object.new_record?
            caller_class.post('', { caller_class.model_name_downcase => object.safe_table_hash })
          else
            caller_class.put(object.id, { caller_class.model_name_downcase => object.safe_table_hash })
          end
        end
        
      end

    end
  end
end
