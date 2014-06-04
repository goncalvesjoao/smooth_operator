require "spec_helper"

describe SmoothOperator::RemoteCall do

  context "when the server response has a http code in the 200 range" do
    before(:all) do
      @subject = UserWithAddressAndPosts::Son.new(attributes_for(:user_with_address_and_posts))
      @subject.save(nil, { status: 200 })
    end

    it "#ok? should return true" do
      expect(@subject.last_remote_call.ok?).to be true
    end

    it "#not_processed? should return false" do
      expect(@subject.last_remote_call.not_processed?).to be false
    end

    it "#client_error? should return false" do
      expect(@subject.last_remote_call.client_error?).to be false
    end

    it "#server_error? should return false" do
      expect(@subject.last_remote_call.server_error?).to be false
    end

    it "#error? should return false" do
      expect(@subject.last_remote_call.error?).to be false
    end

    it "#not_found? should return false" do
      expect(@subject.last_remote_call.not_found?).to be false
    end

    it "#timeout? should return false" do
      expect(@subject.last_remote_call.timeout?).to be false
    end

    it "#connection_failed? should return false" do
      expect(@subject.last_remote_call.connection_failed?).to be false
    end

    it "#status should return true" do
      expect(@subject.last_remote_call.status).to be true
    end
  end

  context "when the server response has a http code in the 400 range (not 422, 404)" do
    before(:all) do
      @subject = UserWithAddressAndPosts::Son.new(attributes_for(:user_with_address_and_posts))
      @subject.save(nil, { status: 400 })
    end

    it "#ok? should return false" do
      expect(@subject.last_remote_call.ok?).to be false
    end

    it "#not_processed? should return false" do
      expect(@subject.last_remote_call.not_processed?).to be false
    end

    it "#client_error? should return true" do
      expect(@subject.last_remote_call.client_error?).to be true
    end

    it "#server_error? should return false" do
      expect(@subject.last_remote_call.server_error?).to be false
    end

    it "#error? should return true" do
      expect(@subject.last_remote_call.error?).to be true
    end

    it "#not_found? should return false" do
      expect(@subject.last_remote_call.not_found?).to be false
    end

    it "#timeout? should return false" do
      expect(@subject.last_remote_call.timeout?).to be false
    end

    it "#connection_failed? should return false" do
      expect(@subject.last_remote_call.connection_failed?).to be false
    end

    it "#status should return nil" do
      expect(@subject.last_remote_call.status).to be nil
    end
  end

  context "when the server response has a http is 404" do
    before(:all) do
      @subject = UserWithAddressAndPosts::Son.new(attributes_for(:user_with_address_and_posts))
      @subject.save(nil, { status: 404 })
    end

    it "#ok? should return false" do
      expect(@subject.last_remote_call.ok?).to be false
    end

    it "#not_processed? should return false" do
      expect(@subject.last_remote_call.not_processed?).to be false
    end

    it "#client_error? should return true" do
      expect(@subject.last_remote_call.client_error?).to be true
    end

    it "#server_error? should return false" do
      expect(@subject.last_remote_call.server_error?).to be false
    end

    it "#error? should return true" do
      expect(@subject.last_remote_call.error?).to be true
    end

    it "#not_found? should return true" do
      expect(@subject.last_remote_call.not_found?).to be true
    end

    it "#timeout? should return false" do
      expect(@subject.last_remote_call.timeout?).to be false
    end

    it "#connection_failed? should return false" do
      expect(@subject.last_remote_call.connection_failed?).to be false
    end

    it "#status should return nil" do
      expect(@subject.last_remote_call.status).to be nil
    end
  end

  context "when the server response has a http is 422" do
    before(:all) do
      @subject = UserWithAddressAndPosts::Son.new(attributes_for(:user_with_address_and_posts))
      @subject.save(nil, { status: 422 })
    end

    it "#ok? should return false" do
      expect(@subject.last_remote_call.ok?).to be false
    end

    it "#not_processed? should return true" do
      expect(@subject.last_remote_call.not_processed?).to be true
    end

    it "#client_error? should return true" do
      expect(@subject.last_remote_call.client_error?).to be true
    end

    it "#server_error? should return false" do
      expect(@subject.last_remote_call.server_error?).to be false
    end

    it "#error? should return false" do
      expect(@subject.last_remote_call.error?).to be false
    end

    it "#not_found? should return false" do
      expect(@subject.last_remote_call.not_found?).to be false
    end

    it "#timeout? should return false" do
      expect(@subject.last_remote_call.timeout?).to be false
    end

    it "#connection_failed? should return false" do
      expect(@subject.last_remote_call.connection_failed?).to be false
    end

    it "#status should return false" do
      expect(@subject.last_remote_call.status).to be false
    end
  end

  context "when the server response has a http code in the 500 range" do
    before(:all) do
      @subject = UserWithAddressAndPosts::Son.new(attributes_for(:user_with_address_and_posts))
      @subject.save(nil, { status: 500 })
    end

    it "#ok? should return false" do
      expect(@subject.last_remote_call.ok?).to be false
    end

    it "#not_processed? should return false" do
      expect(@subject.last_remote_call.not_processed?).to be false
    end

    it "#client_error? should return false" do
      expect(@subject.last_remote_call.client_error?).to be false
    end

    it "#server_error? should return true" do
      expect(@subject.last_remote_call.server_error?).to be true
    end

    it "#error? should return true" do
      expect(@subject.last_remote_call.error?).to be true
    end

    it "#not_found? should return false" do
      expect(@subject.last_remote_call.not_found?).to be false
    end

    it "#timeout? should return false" do
      expect(@subject.last_remote_call.timeout?).to be false
    end

    it "#connection_failed? should return false" do
      expect(@subject.last_remote_call.connection_failed?).to be false
    end

    it "#status should return nil" do
      expect(@subject.last_remote_call.status).to be nil
    end
  end

  context "when the connection is broken" do
    before(:all) do
      @subject = User::BrokenConnection.new
      @subject.save
    end

    it "#ok? should return false" do
      expect(@subject.last_remote_call.ok?).to be false
    end

    it "#not_processed? should return false" do
      expect(@subject.last_remote_call.not_processed?).to be false
    end

    it "#client_error? should return false" do
      expect(@subject.last_remote_call.client_error?).to be false
    end

    it "#server_error? should return true" do
      expect(@subject.last_remote_call.server_error?).to be true
    end

    it "#error? should return true" do
      expect(@subject.last_remote_call.error?).to be true
    end

    it "#not_found? should return false" do
      expect(@subject.last_remote_call.not_found?).to be false
    end

    it "#timeout? should return false" do
      expect(@subject.last_remote_call.timeout?).to be false
    end

    it "#connection_failed? should return true" do
      expect(@subject.last_remote_call.connection_failed?).to be true
    end

    it "#status should return nil" do
      expect(@subject.last_remote_call.status).to be nil
    end
  end

  context "when the connection exceeds the timeout", current: true do
    before(:all) do
      @subject = User::TimeoutConnection.new
      @subject.save('/timeout')
    end

    it "#ok? should return false" do
      expect(@subject.last_remote_call.ok?).to be false
    end

    it "#not_processed? should return false" do
      expect(@subject.last_remote_call.not_processed?).to be false
    end

    it "#client_error? should return false" do
      expect(@subject.last_remote_call.client_error?).to be false
    end

    it "#server_error? should return true" do
      expect(@subject.last_remote_call.server_error?).to be true
    end

    it "#error? should return true" do
      expect(@subject.last_remote_call.error?).to be true
    end

    it "#not_found? should return false" do
      expect(@subject.last_remote_call.not_found?).to be false
    end

    it "#timeout? should return true" do
      expect(@subject.last_remote_call.timeout?).to be true
    end

    it "#connection_failed? should return false" do
      expect(@subject.last_remote_call.connection_failed?).to be false
    end

    it "#status should return nil" do
      expect(@subject.last_remote_call.status).to be nil
    end
  end

  describe "#parsed_response" do
    context "when the server response's body does not contains valid json data" do
      let(:remote_call) { User::Base.find('bad_json') }

      it "it should return what the server has returned" do
        expect(remote_call.data).to eq('ok')
      end
    end
  end

  describe "#http_status" do
    context "when a server connection is established" do
      before do
        @subject = UserWithAddressAndPosts::Son.new(attributes_for(:user_with_address_and_posts))
        @subject.save(nil, { status: 422 })
      end

      it "it should return the server's http response code" do
        expect(@subject.last_remote_call.http_status).to be 422
      end
    end

    context "when a server connection fails" do
      before do
        @subject = User::TimeoutConnection.new
        @subject.save('/timeout')
      end

      it "should return 0" do
        expect(@subject.last_remote_call.http_status).to be 0
      end
    end
  end

end
