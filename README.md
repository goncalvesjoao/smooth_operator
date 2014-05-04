# SmoothOperator

Ruby gem, that mimics the ActiveRecord behaviour but through external API's.
It's a lightweight and flexible alternative to ActiveResource, that responds to a REST API like you expect it too.

Depends only on Faraday gem, no need for ActiveSupport or any other Active* gem.

Although if I18n is present it will respond to .human_attribute_name method and if ActiveModel is present it will make use of 'ActiveModel::Name' to improve .model_name method.

---

## 1) Installation

Add this line to your application's Gemfile:

    gem 'smooth_operator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install smooth_operator

---

## 2) Usage and Examples

```ruby
class MyBlogResource < SmoothOperator::Base
  self.endpoint = 'http://myblog.com/api/v0'

  # HTTP BASIC AUTH
  self.endpoint_user = 'admin'
  self.endpoint_pass = 'admin'
end

class Post < MyBlogResource
end
```

---

### 2.1) Creating a .new 'Post' and #save it

```ruby
post = Post.new( body: 'my first post', author: 'John Doe' )

post.new_record?     # true
post.persisted?     # false
post.body           # 'my first post'
post.author         # 'John Doe'
post.something_else # will raise NoMethodError

save_result = post.save # will make a http POST call to 'http://myblog.com/api/v0/posts'
                        # with `{ post: { body: 'my first post', author: 'John Doe' } }`

post.last_remote_call # will contain a SmoothOperator::RemoteCall instance containing relevant information about the save remote call.

# If the server response is positive (http code between 200 and 299):
save_result       # true
post.new_record?  # false
post.persisted?   # true
# server response contains { id: 1 } on its body
post.id # 1

# If the server response is negative (http code between 400 and 499):
save_result       # false
post.new_record?  # true
post.persisted?   # false
# server response contains { errors: { body: ['must be less then 10 letters'] } }
post.errors.body # Array

# If the server response is an error (http code between 500 and 599), or the connection was broke:
save_result       # nil
post.new_record?  # true
post.persisted?   # false
# server response contains { errors: { body: ['must be less then 10 letters'] } }
post.errors # will raise NoMethodError

  # In the positive and negative server response comes with a json,
  # e.g. { id: 1 }, post will reflect that new data
  post.id # 1

  # In case of error and the server response contains a json,
  # e.g. { id: 1 }, post will NOT reflect that data
  post.id # raise NoMethodError

```

---

### 2.2) Customize #save 'url', 'params' and 'options'
```ruby
post = Post.new( id: 2, body: 'editing my second page' )

post.new_record? # false
post.persisted?  # true

post.save("#{post.id}/save_and_add_to_list", { admin: true, post: { author: 'Agent Smith', list_id: 1 } }, { timeout: 1 })
# Will make a PUT to 'http://myblog.com/api/v0/posts/2/save_and_add_to_list'
# with { admin: true, post: { body: 'editing my second page', list_id: 1 } }
# and will only wait 1sec for the server to respond.
```

---

### 2.3) Saving using HTTP Patch verb
```ruby
class Page < MyBlogResource
  self.save_http_verb = :patch
end

page = Page.new( id: 2, body: 'editing my second page' )

page.save # will make a http PATCH call to 'http://myblog.com/api/v0/pages/2'
          # with `{ page: { body: 'editing my second page' } }`
```

---

### 2.4) Retrieving remote objects - 'index' REST action

```ruby
remote_call = Page.find(:all) # Will make a GET call to 'http://myblog.com/api/v0/pages'
                              # and will return a SmoothOperator::RemoteCall instance

pages = remote_call.objects # 'pages = remote_call.data' also works

# If the server response is positive (http code between 200 and 299):
  remote_call.success? # true
  remote_call.failure? # false
  remote_call.error? # false
  remote_call.status # true
  pages = remote_call.data # array of Page instances
  remote_call.http_status # server_response code

# If the server response is negative (http code between 400 and 499):
  remote_call.success? # false
  remote_call.failure? # true
  remote_call.error? # false
  remote_call.status # false
  remote_call.http_status # server_response code

# If the server response is an error (http code between 500 and 599), or the connection broke:
  remote_call.success? # false
  remote_call.failure? # false
  remote_call.error? # true
  remote_call.status # nil
  remote_call.http_status # server_response code or 0 if connection broke
```

---

### 2.5) Retrieving remote objects - 'show' REST action

```ruby
remote_call = Page.find(2) # Will make a GET call to 'http://myblog.com/api/v0/pages/2'
                           # and will return a SmoothOperator::RemoteCall instance

page = remote_call.object # 'page = remote_call.data' also works
```

---

### 2.6) Retrieving remote objects - custom query
```ruby
remote_call = Page.find('my_pages', { q: body_contains: 'link' }, { endpoint_user: 'admin', endpoint_pass: 'new_password' })
# will make a GET call to 'http://myblog.com/api/v0/pages/my_pages?q={body_contains="link"}'
# and will change the HTTP BASIC AUTH credentials to user: 'admin' and pass: 'new_password' for this connection only.

# If the server json response is an Array [{ id: 1 }, { id: 2 }]
  pages = remote.data # will return an array with 2 Page's instances
  pages[0].id # 1
  pages[1].id # 2

# If the server json response is a Hash { id: 3 }
  page = remote.data # will return a single Page instance
  page.id # 3

# If the server json response is Hash with a key called 'pages' { page: 1, total: 3, pages: [{ id: 4 }, { id: 5 }] }
  pages = remote.data # will return a single ArrayWithMetaData instance, that will allow you to access to both the Page's instances array and the metadata.
  pages.page # 1
  pages.total # 3

  pages[0].id # 4
  pages[1].id # 5
```

---

## 3) Methods

---

### 3.1) Persistence methods

Methods | Behaviour | Arguments | Return
------- | --------- | ------ | ---------
.create | Generates a new instance of the class with *attributes and calls #save with the rest of its arguments| Hash attributes = nil, String relative_path = nil, Hash data = {}, Hash options = {} | Class instance
#new_record? | Returns @new_record if defined, else populates it with true if #id is present or false if blank. | - | Boolean
#destroyed?| Returns @destroyed if defined, else populates it with false. | - | Boolean
#persisted?| Returns true if both #new_record? and #destroyed? return false, else returns false. | - | Boolean
#save | if #new_record? makes a HTTP POST, else a PUT call. If !#new_record? and relative_path is blank, sets relative_path = id.to_s. If the server POST response is positive, sets @new_record = false. See 4.2) for more behaviour info. | String relative_path = nil, Hash data = {}, Hash options = {} | Boolean or Nil
#save! | Executes the same behaviour as #save, but will raise RecordNotSaved if the returning value is not true | String relative_path = nil, Hash data = {}, Hash options = {} | Boolean or Nil
#destroy | Does nothing if !persisted? else makes a HTTP DELETE call. If server response it positive, sets @destroyed = true. If relative_path is blank, sets relative_path = id.to_s. See 4.2) for more behaviour info. | String relative_path = nil, Hash data = {}, Hash options = {} | Boolean or Nil

---

### 3.2) Finder methods

Methods | Behaviour | Arguments | Return
------- | --------- | ------ | ---------
.all | calls .find(:all, data, options) | Hash data = {}, Hash options = {} | Class instance, Array of Class instances or an ArrayWithMetaData instance
.find | If relative_path == :all, sets relative_path = ''. Makes a Get call and initiates Class objects with the server's response data. See 4.3) and 4.4) for more behaviour info. | String relative_path, Hash data = {}, Hash options = {} | Class instance, Array of Class instances or an ArrayWithMetaData instance

---

### 3.3) Operator methods
...

---

### 3.3) Remote call methods
...

---

## 4) Behaviours

---

### 4.1) Delegation behaviour
...

---

### 4.2) Persistent operator behaviour
...

---

### 4.3) Operator behaviour
...

---

### 4.4) Remote call behaviour
...

---

## 4) TODO

1. Finish "Methods" and "Behaviours" documentation;
2. Allow changing the HTTP verb for a specific connection;
3. FinderMethods specs;
4. serialization_specs to test the json options for nested classes;
5. model_schema_specs;
6. Cache.
