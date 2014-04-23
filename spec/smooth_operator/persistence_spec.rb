require "spec_helper"


shared_examples_for "after save call procedure" do
  xit "it should populate 'internal_data' with the server's response" do
    expect(user_instance.attr_from_server).to be(true)
  end

  xit "it should populate 'last_remote_call' with the remote_call used on this transaction" do
    expect(user_instance.last_remote_call.response.env.url.to_s).to eq(save_url)
  end
end

shared_examples_for "positive remote call" do
  it "it should return true" do
    expect(method_result).to be true
  end

  it_behaves_like "after save call procedure"
end

shared_examples_for "negative remote call" do
  it "it should return false" do
    expect(method_result).to be false
  end

  it_behaves_like "after save call procedure"
end

shared_examples_for "error remote call" do
  it "it should return nil" do
    expect(method_result).to be_nil
  end

  it "it should NOT alter 'internal_data'" do
    expect(user_instance.respond_to?(:attr_from_server)).to be(false)
  end

  xit "it should populate 'last_remote_call' with the remote_call used on this transaction" do
  end
end

shared_examples_for "save method" do
  xit "it should make a http call with the contents of 'internal_data'" do
    assert_requested :any, save_url, :body => { user_instance.model_name => user_instance.to_hash }
  end
end

shared_examples_for "create method" do
  it "it should make a post http call" do
    assert_requested :post, save_url, times: times
  end

  it_behaves_like "save method"
end

shared_examples_for "update method" do
  it "it should make a put http call" do
    assert_requested :put, save_url, times: times
  end

  it_behaves_like "save method"
end

shared_examples_for "destroy method" do
  it "it should make a delete http call" do
    assert_requested :delete, save_url, times: times
  end
end


describe SmoothOperator::Persistence do

  subject { UserWithAddressAndPosts::Son }

  let(:user_with_data) { subject.new(attributes_for(:user_with_address_and_posts)) }

  let(:save_url) { "http://localhost:3000/v0/users/1" }

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
      before { stub_request(:any, save_url).to_return(:body => "{ 'attr_from_server': 'true' }", :status => 200) }

      it "it should return true" do
        user_with_data.destroy
        expect(user_with_data.destroyed?).to be(true)
      end
    end
  
    context "after a failed execution of #destroy" do
      before { stub_request(:any, save_url).to_return(:body => "{ 'attr_from_server': 'true' }", :status => 404) }

      it "it should return false" do
        user_with_data.destroy
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
        before { stub_request(:any, save_url).to_return(:body => "{ 'attr_from_server': 'true' }", :status => 200) }

        it "it should return false" do
          user_instance.destroy
          expect(user_instance.persisted?).to be(false)
        end
      end

      context "after a failed #destroy" do
        before { stub_request(:any, save_url).to_return(:body => "{ 'attr_from_server': 'true' }", :status => 500) }

        it "it should return true" do
          user_instance.destroy
          expect(user_instance.persisted?).to be(true)
        end
      end
    end
  end  

  describe "#save" do

    let(:method_result) { user_instance.save }

    context "when an instance is NOT persisted" do
      let(:save_url) { "http://localhost:3000/v0/users/" }
      let(:user_instance) { subject.new( observations: '123' ) }

      context "when the response is positive" do
        let(:times) { 1 }
        before { stub_request(:any, save_url).to_return(:body => "{ 'attr_from_server': 'true' }", :status => 200) }

        it_behaves_like "positive remote call"
        it_behaves_like "create method"
      end

      context "when the response is negative" do
        let(:times) { 2 }
        before { stub_request(:any, save_url).to_return(:body => "{ 'attr_from_server': 'true' }", :status => 404) }

        it_behaves_like "negative remote call"
        it_behaves_like "create method"
      end

      context "when the there is a connection error ou http 500" do
        let(:times) { 3 }
        before { stub_request(:any, save_url).to_return(:body => "{ 'attr_from_server': 'true' }", :status => 500) }

        it_behaves_like "error remote call"
        it_behaves_like "create method"
      end
    end

    context "when an instance IS persisted" do
      let(:user_instance) { subject.new(attributes_for(:user_with_address_and_posts)) }

      context "when the response is positive" do
        let(:times) { 1 }
        before { stub_request(:any, save_url).to_return(:body => "{ 'attr_from_server': 'true' }", :status => 200) }

        it_behaves_like "positive remote call"
        it_behaves_like "update method"
      end

      context "when the response is negative" do
        let(:times) { 2 }
        before { stub_request(:any, save_url).to_return(:body => "{ 'attr_from_server': 'true' }", :status => 404) }

        it_behaves_like "negative remote call"
        it_behaves_like "update method"
      end

      context "when the there is a connection error ou http 500" do
        let(:times) { 3 }
        before { stub_request(:any, save_url).to_return(:body => "{ 'attr_from_server': 'true' }", :status => 500) }

        it_behaves_like "error remote call"
        it_behaves_like "update method"
      end
    end

  end

  describe "#save!" do
    let(:user_instance) { subject.new(attributes_for(:user_with_address_and_posts)) }

    context "when #save return true" do
      before { stub_request(:any, save_url).to_return(:body => "{ 'attr_from_server': 'true' }", :status => 200) }
      
      it "should return true" do
        expect(user_instance.save!).to be(true)
      end
    end

    context "when #save return false or nil" do
      before { stub_request(:any, save_url).to_return(:body => "{ 'attr_from_server': 'true' }", :status => 500) }

      it "should raise an exception" do
        expect(user_instance.save!).to raise_error 'RecordNotSaved'
      end
    end
  end

  describe "#destroy" do

    context "when an instance is not persisted" do
      before { stub_request(:any, save_url) }

      let(:user_instance) { subject.new( observations: '123' ) }

      let(:method_result) { user_instance.destroy }

      it "it should return false" do
        expect(method_result).to be_falsey
      end

      it "it NOT should make a delete http call" do
        assert_not_requested :delete, save_url, times: 2
      end
    end

    context "when an instance is persisted" do
      let(:method_result) { user_instance.destroy }

      let(:user_instance) { subject.new(attributes_for(:user_with_address_and_posts)) }

      context "when the response is positive" do
        let(:times) { 5 }
        before { stub_request(:any, save_url).to_return(:body => "{ 'attr_from_server': 'true' }", :status => 200) }

        it_behaves_like "positive remote call"
        it_behaves_like "destroy method"
      end

      context "when the response is negative" do
        let(:times) { 6 }
        before { stub_request(:any, save_url).to_return(:body => "{ 'attr_from_server': 'true' }", :status => 404) }

        it_behaves_like "negative remote call"
        it_behaves_like "destroy method"
      end

      context "when the there is a connection error ou http 500" do
        let(:times) { 7 }
        before { stub_request(:any, save_url).to_return(:body => "{ 'attr_from_server': 'true' }", :status => 500) }

        it_behaves_like "error remote call"
        it_behaves_like "destroy method"
      end
    end
  end

end
