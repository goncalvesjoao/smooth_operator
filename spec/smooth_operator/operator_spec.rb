require "spec_helper"

describe SmoothOperator::Operator do
  subject { User::Base }

  describe "#get" do

    context "submiting a hash, with an array" do

      it 'should correctly encode that hash' do
        remote_call = subject.get('test_hash_with_array', attributes_for(:user_with_address_and_posts))
        
        expect(remote_call.status).to eq(true)
      end

    end

    it "should send the extra params set by .query_string method" do
      remote_call = subject.get('test_query_string', { normal_param: true })

      expect(remote_call.status).to eq(true)
    end

  end

  describe "#post" do

    context "submiting a hash, with an array" do

      it 'should correctly encode that hash' do
        remote_call = subject.post('test_hash_with_array', attributes_for(:user_with_address_and_posts))

        expect(remote_call.status).to eq(true)
      end

    end

    it "should send the extra params set by .query_string method" do
      remote_call = subject.post('test_query_string', { normal_param: true })

      expect(remote_call.status).to eq(true)
    end

  end

end
