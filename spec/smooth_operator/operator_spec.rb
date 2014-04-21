require "spec_helper"

describe SmoothOperator::Operator do
  let(:hash_with_array) { { user: { first_name: 'John', posts: [{ body: 'post1' }, { body: 'post2' }] } } }

  describe "#get" do

    context "submiting a hash, with an array" do
      
      before do
        stub_request(:get, "http://localhost:3000/api/v0/users/").
          to_return(:status => 200)
      end

      it 'should correctly encode that hash' do
        remote_call = User::Base.get('', hash_with_array)

        expect(remote_call.status).to eq(200)
      end

    end

  end

  describe "#post" do

    context "submiting a hash, with an array" do

      before do
        stub_request(:post, "http://localhost:3000/api/v0/users/").
          with(:body => hash_with_array).to_return(:status => 200)
      end

      it 'should correctly encode that hash' do
        remote_call = User::Base.post('', hash_with_array)
        
        expect(remote_call.status).to eq(200)
      end

    end

  end

end
