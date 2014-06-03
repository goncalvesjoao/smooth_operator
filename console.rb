#!/usr/bin/env ruby

$LOAD_PATH << './'
$LOAD_PATH << './lib'

require 'spec/require_helper'

FactoryGirl.find_definitions

LocalhostServer.new(TestServer.new, 4567)

# user = nil

# hydra = Typhoeus::Hydra::hydra

# user = User::Base.new(id: 1)
# user.reload(nil, nil, { hydra: hydra })

# User::Base.find(1, nil, { hydra: hydra }) do |remote_call|
#   user = remote_call.data
# end

#User::Base.post('', { user: { age: 1, posts: [{ body: 'post1' }, 2] } })

#user = UserWithAddressAndPosts::Son.new(FactoryGirl.attributes_for(:user_with_address_and_posts))
#user.save('', { status: 200 })

# "[{\"patient_id\"=>33, \"messages\"=>[{\"id\"=>\"53722c20cb38247c36000003\", \"title\"=>\"Joao Goncalves\", \"created_at\"=>\"2014-05-13T14:28:48Z\"}, {\"id\"=>\"53722bfccb382485d5000002\", \"title\"=>\"Joao Goncalves\", \"created_at\"=>\"2014-05-13T14:28:12Z\"}, {\"id\"=>\"53722b91cb3824e913000001\", \"title\"=>\"Joao Goncalves\", \"created_at\"=>\"2014-05-13T14:26:25Z\"}]}]"

post = Post.new(comments: [{ id: 1, name: '1' }, { id: 2, name: '2' }], address: { id: 1, name: 'address' })

comments_attributes = { "0" => { id: 1, name: '3' }, "1" => { name: '4' } }

comments_with_errors = { "0" => { id: 1, name: '3', errors: { body: ["can't be blank"] } }, "1" => { name: '4', errors: { body: ["can't be blank"] } } }

binding.pry
