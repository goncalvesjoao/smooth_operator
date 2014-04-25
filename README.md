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

TODO: Write usage instructions here


## TODO

1. FinderMethods
2. Turn on/off the casting of unknown hashes into OpenStruct class
3. serialization_specs to test the json options for nested classes
4. Cache 