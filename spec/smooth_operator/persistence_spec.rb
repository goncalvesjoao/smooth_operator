require "spec_helper"

shared_examples_for "successful persistent remote call" do
  it "it should populate 'internal_data' with the server's response" do
    execute_method
    expect(subject.server_response).to be true
  end

  it "it should populate 'last_remote_call' with the remote_call used on this transaction" do
    expect(subject.last_remote_call).to be_nil unless method_to_execute.to_s =~ /create/
    execute_method
    expect(subject.last_remote_call).to be_a_kind_of(SmoothOperator::RemoteCall::Base)
  end
end

shared_examples_for "persistent remote call" do
  it "should send the extra params set by .query_string method" do
    execute_method
    expect(subject.last_remote_call.parsed_response['query_params']).to be true
  end

  context "when the response is positive" do
    let(:method_arguments) { ['', { status: 200 }] }

    it "it should return true" do
      execute_method
      expect(subject.last_remote_call.success?).to be true
      expect(subject.last_remote_call.status).to be true
    end

    it "it should assert the subject's persistence" do
      execute_method
      expect(subject.persisted?).to be(persistence_state[200])
    end

    it_behaves_like "successful persistent remote call"
  end

  context "when the response is negative" do
    let(:method_arguments) { ['', { status: 422 }] }

    it "it should return false" do
      execute_method
      expect(subject.last_remote_call.failure?).to be true
      expect(subject.last_remote_call.status).to be false
    end

    it "it should assert the subject's persistence" do
      execute_method
      expect(subject.persisted?).to be(persistence_state[422])
    end

    it_behaves_like "successful persistent remote call"
  end

  context "when the there is a connection error ou http 500" do
    let(:method_arguments) { ['', { status: 500 }] }

    it "it should return nil" do
      execute_method
      expect(subject.last_remote_call.error?).to be true
      expect(subject.last_remote_call.status).to be_nil
    end

    it "it should NOT alter 'internal_data'" do
      execute_method
      expect(subject.respond_to?(:server_response)).to be(false)
    end

    it "it should populate 'last_remote_call' with the remote_call used on this transaction" do
      expect(subject.last_remote_call).to be_nil unless method_to_execute.to_s =~ /create/
      execute_method
      expect(subject.last_remote_call).to be_a_kind_of(SmoothOperator::RemoteCall::Base)
    end

    it "it should assert the subject's persistence" do
      execute_method
      expect(subject.persisted?).to be(persistence_state[500])
    end
  end
end

shared_examples_for "save method" do
  it "it should make a http call with the contents of 'internal_data'" do
    execute_method
    expect(subject.last_remote_call.parsed_response['internal_data_match']).to be true
  end
end


describe SmoothOperator::Persistence, helpers: :persistence do

  describe "#reload", current: true do
    subject { new_user }

    context "before calling #reload" do
      it "#has_data_from_server and #from_server should return false" do
        expect(subject.from_server).to be_falsey
        expect(subject.has_data_from_server).to be_falsey
      end
    end

    context "when subject doesn't has an id" do
      it "it should raise 'UnknownPath'" do
        expect{ subject.reload }.to raise_error 'UnknownPath'
      end
    end

    context "when subject has an id" do
      before do
        subject.id = 1
        subject.reload
      end

      it "it should fetch server data" do
        expect(subject.attributes).to eq(attributes_for(:user_with_address_and_posts))
      end

      it "#has_data_from_server and #from_server should return true" do
        expect(subject.from_server).to be true
        expect(subject.has_data_from_server).to be true
      end
    end

    context "when calling #reload on a nested object" do
      before do
        subject.id = 1
        subject.reload
        subject.posts.first.reload
      end

      it "it should fetch server data, with the correct nested REST url" do
        # binding.pry
        expect(subject.posts.first.attributes).to eq({ id: 1, body: 'from_server' })
      end
    end
  end

  describe ".create" do
    
    subject { created_subject }
    let(:method_arguments) { [] }

    context "when attributes DON'T contain an ID" do
      let(:method_to_execute) { :create_without_id }
      let(:persistence_state) { { 200 => true, 422 => false, 500 => false } }

      it_behaves_like "persistent remote call"

      it "it should make a post http call" do
        execute_method
        expect(subject.last_remote_call.parsed_response['http_verb']).to eq('post')
      end

      it_behaves_like "save method"
    end

    context "when attributes contain an ID" do
      let(:method_to_execute) { :create_with_id }
      let(:persistence_state) { { 200 => true, 422 => true, 500 => true } }

      it_behaves_like "persistent remote call"

      it "it should make a post http call" do
        execute_method
        expect(subject.last_remote_call.parsed_response['http_verb']).to eq('put')
      end

      it_behaves_like "save method"
    end

  end

  describe "#new_record?" do
    context "when initializing an instance without an id" do
      subject { new_user }

      it "it should return true" do
        expect(subject.new_record?).to be(true)
      end
    end

    context "when initializing an instance with an id" do
      subject { existing_user }

      it "it should return false" do
        expect(subject.new_record?).to be(false)
      end
    end
  end

  describe "#destroyed?" do
    context "before executing #destroy" do
      subject { existing_user }

      it "it should return false" do
        expect(subject.destroyed?).to be_falsey
      end
    end

    context "after a successful execution of #destroy" do
      subject { existing_user }
      before  { subject.destroy('', { status: 200 }) }

      it "it should return true" do
        expect(subject.destroyed?).to be(true)
      end
    end
  
    context "after a failed execution of #destroy" do
      subject { existing_user }
      before  { subject.destroy('', { status: 422 }) }

      it "it should return false" do
        expect(subject.destroyed?).to be(false)
      end
    end

  end

  describe "#persisted?" do
    context "when initializing an instance without an id" do
      subject { new_user }

      it "it should return false" do
        expect(subject.persisted?).to be(false)
      end
    end

    context "when initializing an instance with an id" do

      context "before destroying the instance" do
        subject { existing_user }

        it "it should return true" do
          expect(subject.persisted?).to be(true)
        end
      end

      context "after a successful #destroy" do
        subject { existing_user }
        before  { subject.destroy('', { status: 200 }) }

        it "it should return false" do
          expect(subject.persisted?).to be(false)
        end
      end

      context "after a failed #destroy" do
        subject { existing_user }
        before  { subject.destroy('', { status: 422 }) }

        it "it should return true" do
          expect(subject.persisted?).to be(true)
        end
      end
    end
  end

  describe "#save" do

    let(:method_to_execute) { :save }
    let(:method_arguments) { [] }

    context "when an instance is NOT persisted" do
      subject { new_user }
      let(:persistence_state) { { 200 => true, 422 => false, 500 => false } }

      it_behaves_like "persistent remote call"

      it "it should make a post http call" do
        execute_method
        expect(subject.last_remote_call.parsed_response['http_verb']).to eq('post')
      end

      it_behaves_like "save method"
    end

    context "when an instance IS persisted" do
      context "and it uses 'put' http verb to save" do
        subject { existing_user }
        let(:persistence_state) { { 200 => true, 422 => true, 500 => true } }

        it_behaves_like "persistent remote call"

        it "it should make a put http call" do
          execute_method
          expect(subject.last_remote_call.parsed_response['http_verb']).to eq('put')
        end

        it_behaves_like "save method"
      end

      context "and it uses 'patch' http verb to save" do
        subject { existing_user_with_patch }
        let(:persistence_state) { { 200 => true, 422 => true, 500 => true } }

        it_behaves_like "persistent remote call"

        it "it should make a patch http call" do
          execute_method
          expect(subject.last_remote_call.parsed_response['http_verb']).to eq('patch')
        end

        it_behaves_like "save method"
      end
    end

  end

  describe "#save!" do
    subject { existing_user }

    context "when #save return true" do
      it "should return true" do
        expect(subject.save!('', { status: 200 })).to be(true)
      end
    end

    context "when #save return false or nil" do
      it "should raise an exception" do
        expect { subject.save!('', { status: 500 }) }.to raise_error
      end
    end
  end

  describe "#destroy" do
    
    let(:method_to_execute) { :destroy }
    let(:method_arguments) { [] }

    context "when an instance is not persisted" do
      subject { new_user }

      it "it should return false" do
        expect(execute_method).to be_falsey
      end

      it "it NOT should make a delete http call" do
        expect(subject.last_remote_call).to be_nil
        execute_method
        expect(subject.last_remote_call).to be_nil
      end
    end

    context "when an instance is persisted" do
      subject { existing_user }
      let(:persistence_state) { { 200 => false, 422 => true, 500 => true } }

      it_behaves_like "persistent remote call"

      it "it should make a delete http call" do
        execute_method
        expect(subject.last_remote_call.parsed_response['http_verb']).to eq('delete')
      end
    end

  end

end
