require "spec_helper"

describe SmoothOperator::Operator do

  describe "#get" do

    context "..." do
      
      before do
        stub_request(:get, "http://localhost:3000/api/v0/users/").
          to_return(:status => 200, :body => "", :headers => {})
      end

      it 'it should..' do
        remote_call = User::Base.get

        expect(remote_call.status).to eq(200)
      end

    end

  end

  describe "#post", current: true do

    context "..." do
      before do
        stub_request(:post, "http://localhost:3000/api/v0/users/").
          with(:body => { user: { first_name: 'John' } }).
          to_return(:status => 200, :body => "", :headers => {})
      end

      it 'it should..' do
        remote_call = User::Base.post('', { user: { first_name: 'John', posts: [{ body: 'post1' }, { body: 'post2' }] } })
        
        expect(remote_call.status).to eq(200)
      end

    end

  end

end
