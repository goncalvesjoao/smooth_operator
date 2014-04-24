require "spec_helper"

shared_examples_for "successful persistent remote call" do
  it "it should populate 'internal_data' with the server's response" do
    execute_method
    expect(subject.server_response).to be true
  end

  it "it should populate 'last_remote_call' with the remote_call used on this transaction" do
    expect(subject.last_remote_call).to be_nil
    execute_method
    expect(subject.last_remote_call).to be_instance_of(SmoothOperator::RemoteCall::Base)
  end
end

shared_examples_for "persistent remote call" do
  it "should send the extra params set by .query_string method" do
    execute_method
    expect(subject.last_remote_call.data['query_params']).to be true
  end

  context "when the response is positive" do
    let(:method_arguments) { ['', { status: 200 }] }

    it "it should return true" do
      expect(execute_method).to be true
    end

    it_behaves_like "successful persistent remote call"
  end

  context "when the response is negative" do
    let(:method_arguments) { ['', { status: 422 }] }

    it "it should return false" do
      expect(execute_method).to be false
    end

    it_behaves_like "successful persistent remote call"
  end

  context "when the there is a connection error ou http 500" do
    let(:method_arguments) { ['', { status: 500 }] }

    it "it should return nil" do
      expect(execute_method).to be_nil
    end

    it "it should NOT alter 'internal_data'" do
      execute_method
      expect(subject.respond_to?(:server_response)).to be(false)
    end

    it "it should populate 'last_remote_call' with the remote_call used on this transaction" do
      expect(subject.last_remote_call).to be_nil
      execute_method
      expect(subject.last_remote_call).to be_instance_of(SmoothOperator::RemoteCall::Base)
    end
  end
end

shared_examples_for "save method" do
  it "it should make a http call with the contents of 'internal_data'" do
    execute_method
    expect(subject.last_remote_call.data['internal_data_match']).to be true
  end
end


describe SmoothOperator::Persistence, helpers: :persistence do

  describe ".create" do
    xit '...' do
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

      it_behaves_like "persistent remote call"

      it "it should make a post http call" do
        execute_method
        expect(subject.last_remote_call.data['http_verb']).to eq('post')
      end

      it_behaves_like "save method"
    end

    context "when an instance IS persisted" do
      subject { existing_user }

      it_behaves_like "persistent remote call"

      it "it should make a put http call" do
        execute_method
        expect(subject.last_remote_call.data['http_verb']).to eq('put')
      end

      it_behaves_like "save method"
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
        execute_method
        assert_not_requested :delete, /localhost/, times: 1
      end
    end

    context "when an instance is persisted" do
      subject { existing_user }

      it_behaves_like "persistent remote call"

      it "it should make a delete http call" do
        execute_method
        expect(subject.last_remote_call.data['http_verb']).to eq('delete')
      end
    end

  end

end
