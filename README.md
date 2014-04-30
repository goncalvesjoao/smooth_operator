# SmoothOperator

Ruby gem, that mimics the ActiveRecord behaviour but through external API's.
It's a lightweight and flexible alternative to ActiveResource, that responds to a REST API like you expect it too.

Depends only on Faraday gem, no need for ActiveSupport or any other Active* gem.

Although if I18n is present it will respond to .human_attribute_name method and if ActiveModel is present it will make use of 'ActiveModel::Name' to improve .model_name method.


## Installation

Add this line to your application's Gemfile:

    gem 'smooth_operator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install smooth_operator


## Usage

class MyBlogResource < SmoothOperator::Base
  self.endpoint = 'http://myblog.com/api/v0'

  # HTTP BASIC AUTH
  self.endpoint_user = 'admin'
  self.endpoint_pass = 'admin'
end

class Post < MyBlogResource
end

1.) Example
`post = Post.new( body: 'my first post', author: 'John Doe' )`
will return a SmoothOperator::Base class populated with the assigned hash

  1.1)
  `post.new_record?` -> true
  `post.persisted?` -> false
  `post.body` and `post.author` will return 'my first post', and 'John Doe' respectivly.

  `post.something_else` will raise NoMethodError

  1.2)
  `post.save` will make a http POST call to 'http://myblog.com/api/v0/posts' with `{ post: { body: 'my first post', author: 'John Doe' } }`

  `page.last_remote_call` will contain a SmoothOperator::RemoteCall instance containing relevante information about the save remote call.

  if the server response is positive (http code between 200 and 299):
    - #save will return true,
    - `post.new_record?` -> false,
    - `post.persisted?` -> true, 
    - if the server has returned a json, e.g. { id: 1 }, post data will be reflect that new data `post.id == 1`

  if the server response is negative (http code between 400 and 499):
    - #save will return false,
    - `post.new_record?` -> true,
    - `post.persisted?` -> false, 
    - if the server has returned a json, e.g. { errors: { body: ['must be less than 10 letters'] } }, post data will be reflect that new data `post.errors`

  if the server response is an error (http code between 500 and 599), or the connection was broke:
    - #save will return nil,
    - `post.new_record?` -> true,
    - `post.persisted?` -> false, 
    - if the server has returned a json, e.g. { errors: { body: ['must be less than 10 letters'] } } it will be IGNORED, `post.errors` will raise NoMethodError.

  1.3)
  `post.save('create_and_add_to_list', { add_to_list: true }, { timeout: 1 })`
  will make a POST TO 'http://myblog.com/api/v0/posts/create_and_add_to_list' with `{ add_to_list: true, post: { body: 'my first post', author: 'John Doe' } }` and will only wait 1sec for the server to repond.



2.) Example
`class Page < MyBlogResource

  self.save_http_verb = :patch

end`

`page = Page.new( id: 2, body: 'editing my second page' )`

  2.1)
  `post.new_record?` -> false
  `post.persisted?` -> true

  2.2)
  `page.save` will make a http PATCH call to 'http://myblog.com/api/v0/pages/2' with `{ page: { body: 'editing my second page' } }`

  2.3)
  `page.save(nil, { admin: true, page: author: 'John Doe' })` `page.save` will make a http PATCH call to 'http://myblog.com/api/v0/pages/2' with `{ admin: true, page: { body: 'editing my second page', author: 'John Doe' } }`


3.) Example

  3.1) `Page.find(:all)` will make a GET call to 'http://myblog.com/api/v0/pages' and will return a SmoothOperator::RemoteCall instance

  `remote_call = Page.find(:all)`

  if the server response is positive (http code between 200 and 299):
  - `remote_call.success?` -> true
  - `remote_call.failure?` -> false
  - `remote_call.error?` -> false
  - `remote_call.status` -> true
  - `pages = remote_call.data` -> array of Page's instances
  - `remote_call.http_status` -> either server_response code

  if the server response is negative (http code between 400 and 499):
  - `remote_call.success?` -> false
  - `remote_call.failure?` -> true
  - `remote_call.error?` -> false
  - `remote_call.status` -> false
  - `remote_call.http_status` -> either server_response code

  if the server response is an error (http code between 500 and 599), or the connection was broke:
  - `remote_call.success?` -> false
  - `remote_call.failure?` -> false
  - `remote_call.error?` -> true
  - `remote_call.status` -> nil
  - `remote_call.http_status` -> either server_response code ou 0 if connection broke

  3.2)
  `remote_call = Page.find('my_pages', { q: body_contains: 'link' }, { endpoint_user: 'admin', endpoint_pass: 'new_password' })`
  will make a GET call to 'http://myblog.com/api/v0/pages/my_pages?q={body_contains="link"}' and will change the HTTP BASIC AUTH credentials to user: 'admin' and pass: 'new_password' for this connection only.

  NOTE:
  'remote_call.data' will return either an array on a single Page's instance according to the server's json response.

  3.3)
  `remote_call = Page.find(:all)`

  if the server response is a json { page: 1, total_pages: 3, pages: [{ body: '...'}, { body: '...' }] }

  `pages = remote_call.data` will return a SmoothOperator::ArrayWithMetaData instance that will respond to

  `pages.page` -> 1
  `pages.total_pages` -> 3
  `pages.length` -> 2

  <% pages.each do |page| %>
    <li><%= page.body %></li>
  <% end %>
  

## TODO

1. FinderMethods specs
2. serialization_specs to test the json options for nested classes
3. model_schema_specs
4. Cache 
