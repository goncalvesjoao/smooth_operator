require "spec_helper"


shared_examples_for "a correct after save call procedure" do
  xit "it should populate 'internal_data' with the server's response" do
  end

  it "it should populate 'last_remote_call' with the remote_call used on this transaction" do
    expect(user_instance.last_remote_call.response.env.url.to_s).to eq(save_url)
  end
end

shared_examples_for "remote call" do
  context "when the response is positive" do
    xit "it should return true" do
    end

    it_behaves_like "a correct after save call procedure"
  end

  context "when the response is negative" do
    xit "it should return false" do
    end

    it_behaves_like "a correct after save call procedure"
  end

  context "when the there is a connection error ou http 500" do
    xit "it should return nil" do
    end

    xit "it should NOT alter 'internal_data'" do
    end

    xit "it should populate 'last_remote_call' with the remote_call used on this transaction" do
    end
  end
end

shared_examples_for "remote save call" do
  it "it should make a http call with the contents of 'internal_data'" do
    assert_requested :any, save_url, :body => { user_instance.model_name => user_instance.to_hash }
  end

  it_behaves_like "remote call"
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
      xit "it should return true" do
      end
    end
  
    context "after a failed execution of #destroy" do
      xit "it should return false" do
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
      context "before destroying the instance" do
        it "it should return true" do
          expect(user_with_data.persisted?).to be(true)
        end
      end

      context "after a successful #destroy" do
        xit "it should return false" do
          user_with_data.destroy
          expect(user_with_data.persisted?).to be(false)
        end
      end

      context "after a failed #destroy" do
        xit "it should return true" do
          user_with_data.destroy
          expect(user_with_data.persisted?).to be(true)
        end
      end
    end
  end
  
  describe "#save" do

    context "when an instance is NOT persisted" do
      let(:save_url) { "http://localhost:3000/v0/invoices/" }

      let(:user_instance) { subject.new( observations: '123' ) }

      before do
        stub_request(:any, save_url)

        user_instance.save
      end

      it "it should make a post http call" do
        assert_requested :post, save_url
      end

      it_behaves_like "remote save call"
    end

    context "when an instance IS persisted" do
      let(:save_url) { "http://localhost:3000/v0/invoices/1" }

      let(:user_instance) { subject.new(attributes_for(:user_with_address_and_posts)) }

      before do
        stub_request(:any, save_url)

        user_instance.save
      end

      it "it should make a put http call" do
        assert_requested :put, save_url
      end

      it_behaves_like "remote save call"
    end

  end

  describe "#save!" do
    context "when #save return true" do
      xit "should return true" do
      end
    end

    context "when #save return false or nil" do
      xit "should raise an exception" do
      end
    end
  end

  describe "#destroy" do
    let(:save_url) { "http://localhost:3000/v0/invoices/1" }

    before do
      stub_request(:any, save_url)
    end

    context "when an instance is not persisted" do
      let(:user_instance) { subject.new( observations: '123' ) }

      before do
        user_instance.destroy
      end

      it "it NOT should make a delete http call" do
        assert_not_requested :delete, save_url
      end

      xit "it should return true" do
      end
    end

    context "when an instance is persisted" do
      let(:user_instance) { subject.new(attributes_for(:user_with_address_and_posts)) }

      before do
        stub_request(:any, save_url)

        user_instance.destroy
      end

      it "it should make a delete http call" do
        assert_requested :delete, save_url
      end

      it_behaves_like "remote call"
    end
  end

end
