require "spec_helper"


shared_examples_for "after save call procedure" do
  it "it should populate 'internal_data' with the server's response" do
    run_method
    expect(user_instance.server_response).to be true
  end

  it "it should populate 'last_remote_call' with the remote_call used on this transaction" do
    expect(user_instance.last_remote_call).to be_nil
    run_method
    expect(user_instance.last_remote_call).to be_instance_of(SmoothOperator::RemoteCall::Base)
  end
end

shared_examples_for "positive remote call" do
  it "it should return true" do
    expect(run_method).to be true
  end

  it_behaves_like "after save call procedure"
end

shared_examples_for "negative remote call" do
  it "it should return false" do
    expect(run_method).to be false
  end

  it_behaves_like "after save call procedure"
end

shared_examples_for "error remote call" do
  it "it should return nil" do
    expect(run_method).to be_nil
  end

  it "it should NOT alter 'internal_data'" do
    expect(user_instance.respond_to?(:server_response)).to be(false)
  end

  it "it should populate 'last_remote_call' with the remote_call used on this transaction" do
    expect(user_instance.last_remote_call).to be_nil
    run_method
    expect(user_instance.last_remote_call).to be_instance_of(SmoothOperator::RemoteCall::Base)
  end
end

shared_examples_for "save method" do
  it "it should make a http call with the contents of 'internal_data'" do
    run_method
    expect(user_instance.last_remote_call.data['data_match']).to be true
  end
end

shared_examples_for "create method" do
  it "it should make a post http call" do
    run_method
    expect(user_instance.last_remote_call.data['http_verb']).to eq('post')
  end

  it_behaves_like "save method"
end

shared_examples_for "update method" do
  it "it should make a put http call" do
    run_method
    expect(user_instance.last_remote_call.data['http_verb']).to eq('put')
  end

  it_behaves_like "save method"
end

shared_examples_for "destroy method" do
  it "it should make a delete http call" do
    run_method
    expect(user_instance.last_remote_call.data['http_verb']).to eq('delete')
  end
end


describe SmoothOperator::Persistence do

  subject { UserWithAddressAndPosts::Son }

  let(:user_with_data) { subject.new(attributes_for(:user_with_address_and_posts)) }

  describe ".create" do
    
  end

  describe "#new_record?" do
    context "when initializing an instance without an id" do
      it "it should return true" do
        expect(subject.new.new_record?).to be(true)
      end
    end

    context "when initializing an instance with an id" do
      it "it should return false" do
        expect(user_with_data.new_record?).to be(false)
      end
    end
  end

  describe "#destroyed?" do
    context "before executing #destroy" do
      it "it should return false" do
        expect(user_with_data.destroyed?).to be_falsey
      end
    end

    context "after a successful execution of #destroy" do
      it "it should return true" do
        user_with_data.destroy('', { status: 200 })
        expect(user_with_data.destroyed?).to be(true)
      end
    end
  
    context "after a failed execution of #destroy" do
      it "it should return false" do
        user_with_data.destroy('', { status: 422 })
        expect(user_with_data.destroyed?).to be(false)
      end
    end

  end

  describe "#persisted?" do
    context "when initializing an instance without an id" do
      it "it should return false" do
        expect(subject.new.persisted?).to be(false)
      end
    end

    context "when initializing an instance with an id" do
      
      let(:user_instance) { subject.new(attributes_for(:user_with_address_and_posts)) }

      context "before destroying the instance" do
        it "it should return true" do
          expect(user_with_data.persisted?).to be(true)
        end
      end

      context "after a successful #destroy" do
        it "it should return false" do
          user_instance.destroy('', { status: 200 })
          expect(user_instance.persisted?).to be(false)
        end
      end

      context "after a failed #destroy" do
        it "it should return true" do
          user_instance.destroy('', { status: 422 })
          expect(user_instance.persisted?).to be(true)
        end
      end
    end
  end  

  describe "#save" do

    let(:run_method) { user_instance.save }

    context "when an instance is NOT persisted" do
      let(:user_instance) do
        attributes = attributes_for(:user_with_address_and_posts)
        attributes.delete(:id)
        subject.new(attributes)
      end

      context "when the response is positive" do
        before { user_instance.status = 200 }

        it_behaves_like "positive remote call"
        it_behaves_like "create method"
      end

      context "when the response is negative" do
        before { user_instance.status = 422 }

        it_behaves_like "negative remote call"
        it_behaves_like "create method"
      end

      context "when the there is a connection error ou http 500" do
        before { user_instance.status = 500 }

        it_behaves_like "error remote call"
        it_behaves_like "create method"
      end
    end

    context "when an instance IS persisted" do
      let(:user_instance) { subject.new(attributes_for(:user_with_address_and_posts)) }

      context "when the response is positive" do
        before { user_instance.status = 200 }

        it_behaves_like "positive remote call"
        it_behaves_like "update method"
      end

      context "when the response is negative" do
        before { user_instance.status = 422 }

        it_behaves_like "negative remote call"
        it_behaves_like "update method"
      end

      context "when the there is a connection error ou http 500" do
        before { user_instance.status = 500 }

        it_behaves_like "error remote call"
        it_behaves_like "update method"
      end
    end

  end

  describe "#save!" do
    let(:user_instance) { subject.new(attributes_for(:user_with_address_and_posts)) }

    context "when #save return true" do
      before { user_instance.status = 200 }
      
      it "should return true" do
        expect(user_instance.save!).to be(true)
      end
    end

    context "when #save return false or nil" do
      before { user_instance.status = 500 }

      it "should raise an exception" do
        expect(user_instance.save!).to raise_error 'RecordNotSaved'
      end
    end
  end

  describe "#destroy" do

    context "when an instance is not persisted" do

      let(:user_instance) { subject.new( observations: '123' ) }

      let(:run_method) { user_instance.destroy }

      it "it should return false" do
        expect(run_method).to be_falsey
      end

      it "it NOT should make a delete http call" do
        assert_not_requested :delete, /localhost/, times: 2
      end
    end

    context "when an instance is persisted" do
      let(:user_instance) { subject.new(attributes_for(:user_with_address_and_posts)) }

      context "when the response is positive" do
        let(:run_method) { user_instance.destroy('', status: 200) }

        it_behaves_like "positive remote call"
        it_behaves_like "destroy method"
      end

      context "when the response is negative" do
        let(:run_method) { user_instance.destroy('', status: 422) }

        it_behaves_like "negative remote call"
        it_behaves_like "destroy method"
      end

      context "when the there is a connection error ou http 500" do
        let(:run_method) { user_instance.destroy('', status: 500) }

        it_behaves_like "error remote call"
        it_behaves_like "destroy method"
      end
    end
  end

end
