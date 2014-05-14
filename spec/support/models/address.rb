class Address < SmoothOperator::Base

  self.dirty_attributes

  self.resource_name = ''

  self.endpoint_user = 'admin'
  self.endpoint_pass = 'admin'

  self.endpoint = 'http://localhost:4567/'

  self.headers = { "X-APPTOKEN" => "joaquim_app_token", "X-LAYERTOKEN" => "joaquim_layer_token" }
  
end
