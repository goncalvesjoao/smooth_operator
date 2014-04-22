require "spec_helper"

describe SmoothOperator::Operator do
  subject { User }

  let(:hash_with_array) { { first_name: 'John', age: 3, dob: '2-2-2222', manager: true, posts: [{ body: 'post1' }, { body: 'post2' }] } }

  describe "#get" do

    context "submiting a hash, with an array" do
      
      before do
        stub_request(:get, "http://localhost:3000/api/v0/patient_medicines/")
          .to_return(:status => 200)
      end

      xit 'should correctly encode that hash' do
        remote_call = subject.get('', hash_with_array)

        expect(remote_call.status).to eq(200)
      end

    end

  end

  describe "#post" do

    context "submiting a hash, with an array", current: true do

      before do
        stub_request(:post, "http://localhost:3000/api/v0/patient_medicines/")
          .with(:body => hash_with_array)
          .to_return(:status => 200)
      end

      xit 'should correctly encode that hash' do
        remote_call = subject.post('', hash_with_array)
        
        expect(remote_call.status).to eq(200)
      end

    end

  end

end
