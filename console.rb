#!/usr/bin/env ruby

$LOAD_PATH << './'
$LOAD_PATH << './lib'

require "spec/spec_helper"

#User::Base.post('', { user: { age: 1, posts: [{ body: 'post1' }, 2] } })


conn = SmoothOperator::Base.generate_parallel_connection

conn.in_parallel do
  remote_call = User::Base.find('http://localhost:4567/users', nil, { connection: conn })
end

remote_call

binding.pry

