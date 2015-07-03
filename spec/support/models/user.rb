module User

  class Base < SmoothOperator::Base

    options resource_name: 'user',
            endpoint_user: 'admin',
            endpoint_pass: 'admin',
            endpoint: 'http://localhost:4567/'

    def self.query_string(params)
      params['query_string_param'] = true

      params
    end

    def headers
      { 'PING' => 'PONG' }
    end

  end

  module UnknownHashClass

    class OpenStructBase < User::Base
      options unknown_hash_class: SmoothOperator::OpenStruct
    end

    class None < User::Base
      options unknown_hash_class: nil
    end

  end

  class BrokenConnection < SmoothOperator::Base
    options endpoint: 'http://localhost:1234/'
  end

  class TimeoutConnection < Base
    options timeout: 1
  end

end
