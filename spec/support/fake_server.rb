require 'sinatra/base'
require 'sinatra/json'

class FakeServer < Sinatra::Base

  get '/users' do
    json [{ id: 1 }, { id: 2 }]
  end

  get '/users/test_hash_with_array' do
    status test_hash_with_array
  end

  post '/users/test_hash_with_array' do
    status test_hash_with_array
  end


  protected ################ PROTECTED ################

  def test_hash_with_array
    data = stringify_data FactoryGirl.attributes_for(:user_with_address_and_posts)
binding.pry
    (params == data) ? 200 : 403
  end

  def stringify_data(object)
    if object.is_a?(Hash)
      data = {}
      object.each { |key, value| data[key.to_s] = stringify_data(value) }
      data
    elsif object.is_a?(Array)
      object.map { |_value| stringify_data(_value) }
    else
      object.to_s
    end
  end

end
