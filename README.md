# SmoothOperator

Ruby gem, that mimics the ActiveRecord behaviour but through external API's.
It's a lightweight and flexible alternative to ActiveResource, that responds to a REST API like you expect it too.

Depends only on Faraday gem, no need for ActiveSupport or any other Active* gem.

Although if I18n is present it will respond to .human_attribute_name method and if ActiveModel is present it will make use of 'ActiveModel::Name' to improv the .model_name method.


## Installation

Add this line to your application's Gemfile:

    gem 'smooth_operator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install smooth_operator

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## TODO

# serialization_specs to test the json_options for nested classes

1. FinderMethods
2. Switch between Put and Patch
3. Turn on/off the casting of unknown hashes into OpenStruct class
3. Cache 
