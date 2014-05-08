require "spec_helper"

describe SmoothOperator::RemoteCall, current: true do
  subject { UserWithAddressAndPosts::Son.new(attributes_for(:user_with_address_and_posts)) }

  context "when the server response has a http code in the 200 range" do
    before { subject.save(nil, { status: 200 }) }

    it "#success? should return true" do
      expect(subject.last_remote_call.success?).to be true
    end

    it "#failure? should return false" do
      expect(subject.last_remote_call.failure?).to be false
    end

    it "#error? should return false" do
      expect(subject.last_remote_call.error?).to be false
    end

    it "#not_found? should return false" do
      expect(subject.last_remote_call.not_found?).to be false
    end

    it "#not_processed? should return false" do
      expect(subject.last_remote_call.not_processed?).to be false
    end

    it "#timeout? should return false" do
      expect(subject.last_remote_call.timeout?).to be false
    end

    it "#connection_failed? should return false" do
      expect(subject.last_remote_call.connection_failed?).to be false
    end

    it "#status should return true" do
      expect(subject.last_remote_call.status).to be true
    end
  end

  context "when the server response has a http code in the 400 range" do
    before { subject.save(nil, { status: 400 }) }

    it "#success? should return false" do
      expect(subject.last_remote_call.success?).to be false
    end

    it "#failure? should return true" do
      expect(subject.last_remote_call.failure?).to be true
    end

    it "#error? should return false" do
      expect(subject.last_remote_call.error?).to be false
    end

    it "#not_found? should return false" do
      expect(subject.last_remote_call.not_found?).to be false
    end

    it "#not_processed? should return false" do
      expect(subject.last_remote_call.not_processed?).to be false
    end

    it "#timeout? should return false" do
      expect(subject.last_remote_call.timeout?).to be false
    end

    it "#connection_failed? should return false" do
      expect(subject.last_remote_call.connection_failed?).to be false
    end

    it "#status should return nil" do
      expect(subject.last_remote_call.status).to be nil
    end
  end

  context "when the server response has a http is 404" do
    before { subject.save(nil, { status: 404 }) }

    it "#success? should return false" do
      expect(subject.last_remote_call.success?).to be false
    end

    it "#failure? should return true" do
      expect(subject.last_remote_call.failure?).to be true
    end

    it "#error? should return false" do
      expect(subject.last_remote_call.error?).to be false
    end

    it "#not_found? should return true" do
      expect(subject.last_remote_call.not_found?).to be true
    end

    it "#not_processed? should return false" do
      expect(subject.last_remote_call.not_processed?).to be false
    end

    it "#timeout? should return false" do
      expect(subject.last_remote_call.timeout?).to be false
    end

    it "#connection_failed? should return false" do
      expect(subject.last_remote_call.connection_failed?).to be false
    end

    it "#status should return nil" do
      expect(subject.last_remote_call.status).to be nil
    end
  end

  context "when the server response has a http is 422" do
    before { subject.save(nil, { status: 422 }) }

    it "#success? should return false" do
      expect(subject.last_remote_call.success?).to be false
    end

    it "#failure? should return true" do
      expect(subject.last_remote_call.failure?).to be true
    end

    it "#error? should return false" do
      expect(subject.last_remote_call.error?).to be false
    end

    it "#not_found? should return false" do
      expect(subject.last_remote_call.not_found?).to be false
    end

    it "#not_processed? should return true" do
      expect(subject.last_remote_call.not_processed?).to be true
    end

    it "#timeout? should return false" do
      expect(subject.last_remote_call.timeout?).to be false
    end

    it "#connection_failed? should return false" do
      expect(subject.last_remote_call.connection_failed?).to be false
    end

    it "#status should return false" do
      expect(subject.last_remote_call.status).to be false
    end
  end

  context "when the server response has a http code in the 500 range" do
    before { subject.save(nil, { status: 500 }) }

    it "#success? should return false" do
      expect(subject.last_remote_call.success?).to be false
    end

    it "#failure? should return false" do
      expect(subject.last_remote_call.failure?).to be false
    end

    it "#error? should return true" do
      expect(subject.last_remote_call.error?).to be true
    end

    it "#not_found? should return false" do
      expect(subject.last_remote_call.not_found?).to be false
    end

    it "#not_processed? should return false" do
      expect(subject.last_remote_call.not_processed?).to be false
    end

    it "#timeout? should return false" do
      expect(subject.last_remote_call.timeout?).to be false
    end

    it "#connection_failed? should return false" do
      expect(subject.last_remote_call.connection_failed?).to be false
    end

    it "#status should return nil" do
      expect(subject.last_remote_call.status).to be nil
    end
  end

  context "when the connection is broken" do
    subject { User::BrokenConnection.new }

    before { subject.save }

    it "#success? should return false" do
      expect(subject.last_remote_call.success?).to be false
    end

    it "#failure? should return false" do
      expect(subject.last_remote_call.failure?).to be false
    end

    it "#error? should return true" do
      expect(subject.last_remote_call.error?).to be true
    end

    it "#not_found? should return false" do
      expect(subject.last_remote_call.not_found?).to be false
    end

    it "#not_processed? should return false" do
      expect(subject.last_remote_call.not_processed?).to be false
    end

    it "#timeout? should return false" do
      expect(subject.last_remote_call.timeout?).to be false
    end

    it "#connection_failed? should return true" do
      expect(subject.last_remote_call.connection_failed?).to be true
    end

    it "#status should return nil" do
      expect(subject.last_remote_call.status).to be nil
    end
  end

  context "when the connection exceeds the timeout" do
    subject { User::TimeoutConnection.new }
    
    before { subject.save('timeout') }

    it "#success? should return false" do
      expect(subject.last_remote_call.success?).to be false
    end

    it "#failure? should return false" do
      expect(subject.last_remote_call.failure?).to be false
    end

    it "#error? should return true" do
      expect(subject.last_remote_call.error?).to be true
    end

    it "#not_found? should return false" do
      expect(subject.last_remote_call.not_found?).to be false
    end

    it "#not_processed? should return false" do
      expect(subject.last_remote_call.not_processed?).to be false
    end

    it "#timeout? should return true" do
      expect(subject.last_remote_call.timeout?).to be true
    end

    it "#connection_failed? should return false" do
      expect(subject.last_remote_call.connection_failed?).to be false
    end

    it "#status should return nil" do
      expect(subject.last_remote_call.status).to be nil
    end
  end

  describe "#parsed_response" do
    context "when the server response's body does not contains valid json data" do
      let(:remote_call) { User::Base.find('bad_json') }

      it "should return nil" do
        expect(remote_call.data).to be nil
      end
    end
  end

  describe "#http_status" do
    context "when a server connection is established" do
      before { subject.save(nil, { status: 422 }) }

      it "it should return the server's http response code" do
        expect(subject.last_remote_call.http_status).to be 422
      end
    end

    context "when a server connection fails" do
      subject { User::TimeoutConnection.new }
    
      before { subject.save('timeout') }

      it "should return 0" do
        expect(subject.last_remote_call.http_status).to be 0
      end
    end
  end

end
