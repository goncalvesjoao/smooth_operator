require "smooth_operator/exceptions"

module SmoothOperator
  module ProtocolHandlers
    module HTTParty
      
      class ORM

        def find_each(options, caller_class)
          response = get(nil, options)
          parsed_response = parse_response_or_raise_proper_exception(response, response.code, caller_class)
          return_array_of_objects_or_response(parsed_response, caller_class)
        end

        def find_one(id, options, caller_class)
          response = get(id, options)
          parsed_response = parse_response_or_raise_proper_exception(response, response.code, caller_class)
          caller_class.new(parsed_response)
        end

        def save!(object, caller_class)
          object.last_response = create_or_update(object)

          object.assign_attributes(object.last_response)

          if !caller_class.protocol_handler.successful_response?(object.last_response)
            SmoothOperator::Exceptions.raise_proper_exception(object.last_response, object.last_response.code)
          end

          true
        end

        def destroy(object, caller_class)
          return true if object.new_record?
          
          object.last_response = caller_class.delete(object.id)
          
          object.assign_attributes(object.last_response)

          caller_class.protocol_handler.successful_response?(object.last_response)
        end
        
        private #-------------------------------------- private

        def parse_response_or_raise_proper_exception(response, code, caller_class)
          if caller_class.protocol_handler.successful_response?(response)
            response.parsed_response
          else
            SmoothOperator::Exceptions.raise_proper_exception(response, code)
          end
        end

        def return_array_of_objects_or_response(parsed_response, class_to_be_instantiated)
          if parsed_response.kind_of?(Array)
            parsed_response.map { |attributes| class_to_be_instantiated.new(attributes) }
          else
            parsed_response
          end
        end

        def create_or_update(object, caller_class)
          if new_record?
            caller_class.post('', { caller_class.model_name_downcase => object.safe_table_to_hash })
          else
            caller_class.put(object.id, { caller_class.model_name_downcase => object.safe_table_to_hash })
          end
        end
        
      end

    end
  end
end
