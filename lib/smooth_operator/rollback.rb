module SmoothOperator

	class Rollback < SmoothOperator::Base
    
    def rollback(options = {}, dont_update = false)
    	http_handler_orm.make_the_call(:delete, options, "#{version_id}/rollback") do |remote_call|
        set_raw_response_exception_and_build_proper_response(remote_call)
        
        new_attributes = self.get_attributes(remote_call.parsed_response, self.class.model_name_downcase)
        assign_attributes(new_attributes.slice("id", "version_id"))
      end
    end

  end

end
