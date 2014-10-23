require "spec_helper"

shared_examples_for "finder method" do
  it "it should return a RemoteCall instance with a subject's class instance" do
    expect(user).to be_instance_of(subject)
  end

  it "the instance class should be populated with the returned hash" do
    expect(user.attributes).to eq(attributes_for(:user_with_address_and_posts))
  end
end

describe SmoothOperator::FinderMethods do
  subject { UserWithAddressAndPosts::Son }

  # describe ".all" do
  #   context "when NO arguments are passed" do
  #     it "it should can .find(:all, {}, {})" do
  #       expect(subject).to receive(:find).with(:all, {}, {})
  #       subject.all
  #     end
  #   end

  #   context "when arguments are passed" do
  #     it "it should can .find(:all) with the same arguments that .alll has received" do
  #       arguments = [{ id: 2 }, { http_verb: 'head' }]

  #       expect(subject).to receive(:find).with(:all, *arguments)

  #       subject.all(*arguments)
  #     end
  #   end
  # end

  describe ".find" do
    context "when using parent_object option", current: true do
      it "should return nested data" do
        user = User::Base.new(id: 1)
        remote_call = Post.find(5, nil, parent_object: user)

        expect(remote_call.parsed_response)
          .to eq({ 'id' => 1, 'body' => 'from_nested_url' })
      end
    end

    context "when the server returns a single hash" do
      let(:user) { subject.find(5).data }

      it_behaves_like "finder method"
    end

    context "when the server returns a hash with meta_data" do
      let(:user) { subject.find("5/with_metadata").data }

      it_behaves_like "finder method"

      it "#meta_data should reflect the receiving meta_data" do
        expect(user._meta_data).to eq({ "status" => 1 })
      end

      it "user should NOT contain meta_data" do
        expect { user.status }.to raise_error NoMethodError
      end
    end

    context "when the server returns an array" do
      it "it should return a RemoteCall instance an array that contains a subject's class instance, one for every array's entry" do
        remote_call = subject.find(:all)
        users = remote_call.data

        expect(users).to be_instance_of(Array)
        expect(users[0]).to be_instance_of(subject)
        expect(users[1]).to be_instance_of(subject)
      end

      it "if any of the array entries is not a hash, it shall not be converted or alteread" do
        remote_call = subject.find('misc_array')
        users = remote_call.data

        expect(users).to be_instance_of(Array)
        expect(users[0]).to be_instance_of(subject)
        expect(users[1]).to be(2)
      end
    end

    context "when the server returns a hash with a key (equal to subject's call.resources_name) containing an array" do
      it "it should return a RemoteCall instance an instance of ArrayWithMetaData" do
        remote_call = subject.find('with_metadata')
        users = remote_call.data

        expect(users).to be_instance_of(SmoothOperator::ArrayWithMetaData)
        expect(users.page).to be(1)
        expect(users.total).to be(6)
        users.each { |user| expect(user).to be_instance_of(subject) }
      end
    end

    context "when the server returns an array with nested object on each entry, with the same name has the resource" do
      it "it should return an Array with Class instances" do
        remote_call = subject.find('array_with_nested_users')
        users = remote_call.data

        expect(users).to be_instance_of(Array)
        users.each { |user| expect(user).to be_instance_of(subject) }
      end
    end

  end

end
