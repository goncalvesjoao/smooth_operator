class Address < SmoothOperator::Base

  options resource_name: '',
          endpoint_user: 'admin',
          endpoint_pass: 'admin',
          endpoint: 'http://localhost:4567/',
          headers: {
            "X-APPTOKEN" => "app_token",
            "X-LAYERTOKEN" => "layer_token"
          }

end
