#!/usr/bin/env ruby

$LOAD_PATH << './'
$LOAD_PATH << './lib'

require "spec/spec_helper"

WebMock.allow_net_connect!

#User::Base.post('', { user: { age: 1, posts: [{ body: 'post1' }, 2] } })

binding.pry
