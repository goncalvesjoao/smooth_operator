require 'sinatra/base'
require 'sinatra/json'
require 'pry'

class TestServer < Sinatra::Base

  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    username == 'admin' and password == 'admin'
  end

  get '/posts/:id' do
    post_data = { id: 1, body: 'from_resource_url' }
    json post_data
  end

  get '/users/:id/posts/:id' do
    post_data = { id: 1, body: 'from_nested_url' }
    json post_data
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

  get '/users/array_with_nested_users' do
    nested_users = [{ id: 1, first_name: '1' }, { id: 2, first_name: '2' }]

    users = [{ id: 1, users: nested_users}, { id: 2, users: nested_users}]

    json users
  end

  get '/users/misc_array' do
    json [FactoryGirl.attributes_for(:user_with_address_and_posts), 2]
  end

  get '/users/with_metadata' do
    nested_users = [{ id: 1, first_name: '1' }, { id: 2, first_name: '2' }]

    users = [{ id: 1, users: nested_users}, { id: 2, users: nested_users}]

    data = { page: 1, total: 6, users: users }
    
    json data
  end
  
  get '/users/bad_json' do
    'ok'
  end

  get '/users/:id' do
    json FactoryGirl.attributes_for(:user_with_address_and_posts)
  end

  get '/users/:id/with_metadata' do
    user_data = { user: FactoryGirl.attributes_for(:user_with_address_and_posts), status: 1 }
    json user_data
  end
  

  put '/users/:id/send_error' do
    data_with_error = { id: 1, errors: [{ first_name: ["can't be blank"] }] }
    json data_with_error
  end


  post '/users' do
    common_response
  end
  
  post '/users/timeout' do
    # sleep 2 # for typhoeus tests
    sleep 1
    json 'ok'
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
    # binding.pry
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
    # require './spec/spec_helper' unless defined? SmoothOperator
    # require './spec/require_helper' unless defined? SmoothOperator
    run!
  end

end
