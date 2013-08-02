module SmoothOperator
	module Exceptions

  	extend self

  	def raise_proper_exception(response)
  		return nil if CODES_TO_IGNORE.include?(response.code)
  		exception_to_raise = (CODE_VS_EXCEPTIONS[response.code] || SmoothOperator::Exceptions::Unknown).new(response)
  		raise exception_to_raise, exception_to_raise.message
  	end

		class Base < StandardError
			attr_reader :response

	  	def initialize(response)
		    @response = response
		  end
		end

		class Unknown < SmoothOperator::Exceptions::Base
			def message
	  		'Unknown Error'
	  	end
		end

  	class	NotFound < SmoothOperator::Exceptions::Base
  		def message
	  		'NotFound'
	  	end
  	end

  	class	EntityNotProcessed < SmoothOperator::Exceptions::Base
  		def message
	  		'EntityNotProcessed'
	  	end
  	end

  	class	ServerError < SmoothOperator::Exceptions::Base
  		def message
	  		'ServerError'
	  	end
  	end
  	
  	class	AuthorizationRequired < SmoothOperator::Exceptions::Base
  		def message
	  		'AuthorizationRequired'
	  	end
  	end

		CODES_TO_IGNORE = [200]

  	CODE_VS_EXCEPTIONS = {
  		401 => AuthorizationRequired,
  		422 => EntityNotProcessed,
  	 	404 => NotFound,
  	 	500 => ServerError
  	}

	end
end
