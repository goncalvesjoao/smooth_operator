module User
  
  class Base < SmoothOperator::Base

    # self.timeout = 2
    
    self.model_name = 'user'

    self.endpoint_user = 'admin'

    self.endpoint_pass = 'admin'

    self.endpoint = 'http://localhost:4567/'

    def self.query_string(params)
      params['query_string_param'] = true

      params
    end

  end

  module UnknownHashClass
    
    class OpenStructBase < User::Base
      self.unknown_hash_class = SmoothOperator::OpenStruct::Base
    end

    class None < User::Base
      self.unknown_hash_class = :none
    end

  end

end
