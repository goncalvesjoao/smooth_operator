#!/usr/bin/env ruby

$LOAD_PATH << './'
$LOAD_PATH << './lib'

require 'spec/require_helper'

FactoryGirl.find_definitions

LocalhostServer.new(TestServer.new, 4567)

#User::Base.post('', { user: { age: 1, posts: [{ body: 'post1' }, 2] } })

#user = UserWithAddressAndPosts::Son.new(FactoryGirl.attributes_for(:user_with_address_and_posts))
#user.save('', { status: 200 })

binding.pry

