require 'sinatra/base'
require 'sinatra/json'

class FakeServer < Sinatra::Base


  get '/users/test_hash_with_array' do
    status test_hash_with_array
  end

  post '/users/test_hash_with_array' do
    status test_hash_with_array
  end


  get '/users' do
    json [{ id: 1 }, { id: 2 }]
  end


  post '/users/' do
    common_response
  end

  put '/users/:id' do
    common_response
  end

  delete '/users/:id' do
    common_response
  end

  not_found do
    binding.pry
  end


  protected ################ PROTECTED ################

  def common_response
    status params[:status] || (!params[:user].nil? && params[:user][:status]) || 500
    json({ server_response: true, _status: params[:status], http_verb: env["REQUEST_METHOD"].downcase, data_match: true })
  end

  def test_hash_with_array
    data = stringify_data FactoryGirl.attributes_for(:user_with_address_and_posts)

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

  run! if app_file == $0

end
