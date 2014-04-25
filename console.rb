#!/usr/bin/env ruby

$LOAD_PATH << './'
$LOAD_PATH << './lib'

require "spec/spec_helper"

# WebMock.allow_net_connect!
# stub_request(:any, /localhost/).to_rack(FakeServer)

#User.post('', { user: { age: 1, posts: [{ body: 'post1' }, 2] } })

binding.pry

