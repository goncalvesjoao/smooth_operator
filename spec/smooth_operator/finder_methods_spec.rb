require "spec_helper"

describe SmoothOperator::FinderMethods do
  subject { UserWithAddressAndPosts::Son }

  describe ".all" do
    xit "should can .find(:all) with the same arguments that it as received" do
      
    end
  end

  describe ".find" do
    context "when the server returns a single hash" do
      it "it should return a RemoteCall instance with a subject's class instance populated with the returned hash" do
        remote_call = subject.find(5)
        user = remote_call.object

        expect(user).to be_instance_of(subject)
        expect(user.attributes).to eq(attributes_for(:user_with_address_and_posts))
      end
    end

    context "when the server returns an array" do
      it "it should return a RemoteCall instance an array that contains a subject's class instance, one for every array's entry" do
        remote_call = subject.find(:all)
        users = remote_call.objects

        expect(users).to be_instance_of(Array)
        expect(users[0]).to be_instance_of(subject)
        expect(users[1]).to be_instance_of(subject)
      end

      it "if any of the array entries is not a hash, it shall not be converted or alteread" do
        remote_call = subject.find('misc_array')
        users = remote_call.objects

        expect(users).to be_instance_of(Array)
        expect(users[0]).to be_instance_of(subject)
        expect(users[1]).to be(2)
      end
    end

    context "when the server returns a hash with a key (equal to subject's call.table_name) containing an array" do
      it "it should return a RemoteCall instance an instance of ArrayWithMetaData" do
        remote_call = subject.find('with_metadata')
        users = remote_call.data

        expect(users).to be_instance_of(SmoothOperator::ArrayWithMetaData)
        expect(users.page).to be(1)
        expect(users.total).to be(6)
        users.each { |user| expect(user).to be_instance_of(subject) }
      end
    end
  end

end
