require 'sinatra/base'
require 'sinatra/json'

class TestServer < Sinatra::Base

  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    username == 'admin' and password == 'admin'
  end

  get '/users/test_hash_with_array' do
    status test_hash_with_array
  end

  post '/users/test_hash_with_array' do
    status test_hash_with_array
  end

  get '/users/test_query_string' do
    status test_query_string
  end

  post '/users/test_query_string' do
    status test_query_string
  end


  get '/users' do
    users = [FactoryGirl.attributes_for(:user_with_address_and_posts), FactoryGirl.attributes_for(:user_with_address_and_posts)]
    
    users[0][:id] = 1
    users[1][:id] = 2

    json users
  end

  get '/users/misc_array' do
    json [FactoryGirl.attributes_for(:user_with_address_and_posts), 2]
  end

  get '/users/with_metadata' do
    data = { page: 1, total: 6, users: [{ id: 1 }, { id: 2 }] }
    json data
  end
  
  get '/users/:id' do
    json FactoryGirl.attributes_for(:user_with_address_and_posts)
  end

  put '/users/send_error' do
    data_with_error = { id: 1, errors: { first_name: ["can't be blank"] } }
    json data_with_error
  end


  post '/users' do
    common_response
  end

  put '/users/:id' do
    common_response
  end
  
  patch '/users/:id' do
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
    status params[:status]

    data = stringify_data FactoryGirl.attributes_for(:user_with_address_and_posts)
    data.delete('id')

    query_params = (params[:query_string_param] == 'true')
    
    internal_data_match = params[:user] ? (params[:user] == data) : true

    json({ user: { server_response: true }, http_verb: env["REQUEST_METHOD"].downcase, internal_data_match: internal_data_match, query_params: query_params })
  end

  def test_hash_with_array
    data = stringify_data FactoryGirl.attributes_for(:user_with_address_and_posts)

    params.delete("query_string_param")

    (params == data) ? 200 : 422
  end

  def test_query_string
    params[:normal_param] == 'true' && params[:query_string_param] == 'true' ? 200 : 422
  end


  private ######################### PRIVATE #####################

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

  if app_file == $0
    require './spec/spec_helper' unless defined? SmoothOperator
    run!
  end

end
