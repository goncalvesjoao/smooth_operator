require "spec_helper"

describe SmoothOperator::Operator do
  subject { User }

  describe "#get" do

    context "submiting a hash, with an array", current: true do

      xit 'should correctly encode that hash' do
        remote_call = subject.get('test_hash_with_array', attributes_for(:user_with_address_and_posts))

        expect(remote_call.status).to eq(true)
      end

    end

  end

  describe "#post" do

    context "submiting a hash, with an array" do

      it 'should correctly encode that hash' do
        remote_call = subject.post('test_hash_with_array', attributes_for(:user_with_address_and_posts))
        
        expect(remote_call.status).to eq(true)
      end

    end

  end

end
