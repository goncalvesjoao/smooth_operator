require "spec_helper"


shared_examples_for "a correct after save call procedure" do
  it "it should populate 'internal_data' with the server's response" do
  end

  it "it should populate 'last_save_remote_call' with the remote_call used on this transaction" do
  end
end

shared_examples_for "remote call" do
  context "when the response is positive" do
    it "it should return true" do
    end

    it_behaves_like "a correct after save call procedure"
  end

  context "when the response is negative" do
    it "it should return false" do
    end

    it_behaves_like "a correct after save call procedure"
  end

  context "when the there is a connection error ou http 500" do
    it "it should return nil" do
    end

    it "it should NOT alter 'internal_data'" do
    end

    it "it should populate 'last_save_remote_call' with the remote_call used on this transaction" do
    end
  end
end

shared_examples_for "remote save call" do
  it "it should make a http call with the contents of 'internal_data'" do
  end

  it_behaves_like "remote call"
end


describe SmoothOperator::Persistence do
  subject { User }


  describe ".create" do

    
  end

  describe "#new_record?" do
    context "when initializing an instance without an id" do
      it "it should return true" do
      end
    end

    context "when initializing an instance with an id" do
      it "it should return false" do
      end
    end
  end

  describe "#destroyed?" do
    context "before executing #destroy" do
      it "it should return false" do
      end
    end

    context "after a successful execution of #destroy" do
      it "it should return true" do
      end
    end
  
    context "after a failed execution of #destroy" do
      it "it should return false" do
      end
    end

  end

  describe "#persisted?" do
    context "when initializing an instance without an id" do
      it "it should return false" do
      end
    end

    context "when initializing an instance with an id" do
      context "before destroying the instance" do
        it "it should return true" do
        end
      end

      context "after destroying the instance" do
        it "it should return false" do
        end
      end
    end
  end
  
  describe "#save" do

    context "when an instance is NOT persisted" do
      it "it should make a post http call" do
      end

      it_behaves_like "remote save call"
    end

    context "when an instance IS persisted" do
      it "it should make a put http call" do
      end

      it_behaves_like "remote save call"
    end

  end

  describe "#save!" do
    context "when #save return true" do
      it "should return true" do
      end
    end

    context "when #save return false or nil" do
      it "should raise an exception" do
      end
    end
  end

  describe "#destroy" do
    context "when an instance is not persisted" do
      it "it NOT should make a delete http call" do
      end
    end

    context "when an instance is persisted" do
      it "it should make a delete http call" do
      end

      it_behaves_like "remote call"
    end
  end

end
