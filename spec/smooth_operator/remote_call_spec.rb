require "spec_helper"

describe SmoothOperator::RemoteCall do
  subject { User }

  describe "#success?" do
    context "when the server response has a http code in the 200 range" do
      it "should return true" do
      end
    end

    context "when the server response has a http code NOT in the 200 range" do
      it "should return false" do
      end
    end

    context "when the server response connection fails" do
      it "should return false" do
      end
    end
  end

  describe "#failure?" do
    context "when the server response has a http code in the 400 range" do
      it "should return true" do
      end
    end

    context "when the server response has a http code NOT in the 400 range" do
      it "should return false" do
      end
    end

    context "when the server response connection fails" do
      it "should return false" do
      end
    end
  end

  describe "#error?" do
    context "when the server response has a http code in the 500 range" do
      it "should return true" do
      end
    end

    context "when the server response has a http code NOT in the 500 range" do
      it "should return false" do
      end
    end

    context "when the server response connection fails" do
      it "should return true" do
      end
    end
  end

  describe "#parsed_response" do
    context "when the server response's body contains valid json data" do
      it "should return the parsed result of that data" do
      end
    end

    context "when the server response's body does not contains valid json data" do
      it "should return nil" do
      end
    end
  end

  describe "#status" do
    context "when the #error? returns true" do
      it "should return nil" do
      end
    end

    context "when the #error? returns false and #success? returns true" do
      it "should return true" do
      end
    end

    context "when the #error? returns false and #success? returns false" do
      it "should return false" do
      end
    end
  end

  describe "#http_status" do
    context "when a server connection is established" do
      it "should return the server's http response code" do
      end
    end

    context "when a server connection fails" do
      it "should return 0" do
      end
    end
  end

end
