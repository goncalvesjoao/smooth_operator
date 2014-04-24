class User < SmoothOperator::Base

  self.endpoint = 'http://localhost:4567/'

  def self.query_string(params)
    params['query_string_param'] = true
    
    params
  end

end
