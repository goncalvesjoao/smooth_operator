require 'date'
require "spec_helper"

describe SmoothOperator::AttributeAssignment do

  describe "#assign_attributes" do

    describe "receiving data from server" do
      subject { User::Base.new }

      context "when receiving a Hash with meta_data on it" do
        before { subject.assign_attributes({ user: attributes_for(:user), status: 1 }) }

        it "#meta_data should reflect the receiving meta_data" do
          expect(subject._meta_data).to eq({ "status" => 1 })
        end

        it "subject should NOT contain meta_data" do
          expect{ subject.status }.to raise_error NoMethodError
        end

        it "subject should contain all other data" do
          expect(subject.attributes).to eq(attributes_for(:user))
        end
      end

    end

    describe "white and black list" do
      subject { UserWithAddressAndPosts::Son.new(attributes_for(:user_with_address_and_posts)) }

      context "when there are no changes to attributes's white and black list" do
        it 'it should return all attributes' do
          expect(subject.to_hash).to eq(attributes_for(:user_with_address_and_posts))
        end
      end

      context "when there are changes to attributes's white list" do
        subject(:user_white_listed) { UserWithAddressAndPosts::UserWhiteListed::Son.new(attributes_for(:user_with_address_and_posts)) }

        it 'it should return only the white listed' do
          expect(user_white_listed.to_hash).to eq(attributes_for(:white_list))
        end
      end

      context "when there are changes to attributes's black list" do
        subject(:user_black_listed) { UserWithAddressAndPosts::UserBlackListed::Son.new(attributes_for(:user_with_address_and_posts)) }

        it 'it should not return the black listed' do
          expect(user_black_listed.to_hash).not_to include(attributes_for(:black_list))
        end
      end
    end

    context "when something other than a hash is introduced" do
      it "should do nothing" do
        [nil, '', [1, 2], 'test', 1, 2].each do |something_other_than_a_hash|
          expect(User::Base.new(something_other_than_a_hash).internal_data).to eq({})
        end
      end
    end

    context "when one of the attribute's value, is an hash and is unknown to the schema" do
      context "when the .unknown_hash_class is unused", current: true do
        subject { User::Base.new(address: { street: 'something', postal_code: { code: '123' } }) }

        it "a new instance of OpenStruct will be initialized with that hash" do
          address = subject.address

          expect(address).to be_instance_of(OpenStruct)
          expect(address.street).to eq('something')

          expect(address.postal_code).to be_instance_of(OpenStruct)
          expect(address.postal_code.code).to eq('123')
        end
      end

      context "when the .unknown_hash_class is set to SmoothOperator::OpenStruct" do
        subject { User::UnknownHashClass::OpenStructBase.new(address: { street: 'something', postal_code: { code: '123' } }) }

        it "a new instance of SmoothOperator::OpenStruct will be initialized with that hash" do
          address = subject.address

          expect(address).to be_instance_of(SmoothOperator::OpenStruct)
          expect(address.street).to eq('something')

          expect(address.postal_code).to be_instance_of(SmoothOperator::OpenStruct)
          expect(address.postal_code.code).to eq('123')
        end
      end

      context "when the .unknown_hash_class is set to :none" do
        subject { User::UnknownHashClass::None.new(creator: { first_name: 'admin', address: { street: 'something' } }) }

        it "the hash will be copied as it is" do
          creator = subject.creator

          expect(creator).to be_instance_of(Hash)
          expect(creator[:first_name]).to eq('admin')

          expect(creator[:address]).to be_instance_of(Hash)
          expect(creator[:address][:street]).to eq('something')
        end
      end
    end

    context "when there is no declared schema" do
      subject { User::Base.new(attributes_for(:user)) }
      let(:expected_internal_data) { SmoothOperator::Helpers.stringify_keys(attributes_for(:user)) }

      it "it should populate 'internal_data' with unaltered duplicate data from the received hash" do
        expect(subject.to_hash).to eq(attributes_for(:user))
      end

      it "it should populate 'known_attributes' with the keys of the received hash" do
        expect(subject.known_attributes.to_a).to match_array(expected_internal_data.keys)
      end
    end

    context "when there is a known schema and the received hash has an attribute" do
      subject { UserWithAddressAndPosts::Son }

      context "that is declared (in schema) as an nil" do

        it "when the attributes's value is '1', should return '1'" do
          expect(subject.new(complex_field: '1').complex_field).to eq('1')
        end

        it "when the attributes's value is ['1', '2'], should return ['1', '2']" do
          expect(subject.new(complex_field: ['1', '2']).complex_field).to eq(['1', '2'])
        end

        it "when the attributes's value is 1, should be converted to 1" do
          expect(subject.new(complex_field: 1).complex_field).to eq(1)
        end

        it "when the attributes's value is { first_name: ['1', '2'] }, should be converted to { first_name: ['1', '2'] }" do
          expect(subject.new(complex_field: { first_name: ['1', '2'] }).complex_field).to eq({ first_name: ['1', '2'] })
        end

        it "when the attributes's value is -1, should be converted to -1" do
          expect(subject.new(complex_field: -1).complex_field).to eq(-1)
        end

        it "when the attributes's value is 0.35, should be converted to 0.35" do
          expect(subject.new(complex_field: 0.35).complex_field).to eq(0.35)
        end

      end

      context "that is declared (in schema) as an integer" do

        it "when the attributes's value is '1', should be converted to 1" do
          expect(subject.new(age: '1').age).to be(1)
        end

        it "when the attributes's value is '-1', should be converted to -1" do
          expect(subject.new(age: '-1').age).to be(-1)
        end

        it "when the attributes's value is 's-10s', should be converted to -10" do
          expect(subject.new(age: 's-10s').age).to be(-10)
        end

        it "when the attributes's value is ' 10s', should be converted to 10" do
          expect(subject.new(age: ' 10s').age).to be(10)
        end

        it "when the attributes's value is 123, should be converted to 123" do
          expect(subject.new(age: 123).age).to be(123)
        end

        it "when the attributes's value is -5, should be converted to -5" do
          expect(subject.new(age: -5).age).to be(-5)
        end

      end

      context "that is declared (in schema) as an float" do

        it "when the attributes's value is '1', should be converted to 1" do
          expect(subject.new(price: '1').price).to eq(1.0)
        end

        it "when the attributes's value is '-1', should be converted to -1" do
          expect(subject.new(price: '-1').price).to eq(-1.0)
        end

        it "when the attributes's value is 's-10s', should be converted to -10" do
          expect(subject.new(price: 's-10s').price).to eq(-10.0)
        end

        it "when the attributes's value is ' 10s', should be converted to 10" do
          expect(subject.new(price: ' 10s').price).to eq(10.0)
        end

        it "when the attributes's value is 123, should be converted to 123" do
          expect(subject.new(price: 123).price).to eq(123.0)
        end

        it "when the attributes's value is -5, should be converted to -5" do
          expect(subject.new(price: -5).price).to eq(-5.0)
        end

        it "when the attributes's value is '12.3', should be converted to 12.3" do
          expect(subject.new(price: '12.3').price).to eq(12.3)
        end

        it "when the attributes's value is 's12.3s', should be converted to 12.3" do
          expect(subject.new(price: 's12.3s').price).to eq(12.3)
        end

        it "when the attributes's value is 's12,3s', should be converted to 12.3" do
          expect(subject.new(price: 's12,3s').price).to eq(12.3)
        end

        it "when the attributes's value is 1.2, should be converted to 1.2" do
          expect(subject.new(price: 1.2).price).to eq(1.2)
        end

      end

      context "that is declared (in schema) as an boolean" do

        it "when the attributes's value is true, should be converted to true" do
          expect(subject.new(manager: true).manager).to be(true)
        end

        it "when the attributes's value is false, should be converted to false" do
          expect(subject.new(manager: false).manager).to be(false)
        end

        it "when the attributes's value is 'true', should be converted to true" do
          expect(subject.new(manager: 'true').manager).to be(true)
        end

        it "when the attributes's value is 'false', should be converted to false" do
          expect(subject.new(manager: 'false').manager).to be(false)
        end

        it "when the attributes's value is '1', should be converted to true" do
          expect(subject.new(manager: '1').manager).to be(true)
        end

        it "when the attributes's value is '0', should be converted to false" do
          expect(subject.new(manager: '0').manager).to be(false)
        end

        it "when the attributes's value is '', should be converted to nil" do
          expect(subject.new(manager: '').manager).to be_nil
        end

        it "when the attributes's value is 'something', should be converted to nil" do
          expect(subject.new(manager: 'something').manager).to be_nil
        end

      end

      context "that is declared (in schema) as an existing class" do

        it "if the attribute's value is an hash a new instance of that class will be initialized with that hash" do
          address = subject.new(address: { street: 'something' }).address

          expect(address).to be_instance_of(Address)
          expect(address.street).to eq('something')
        end

        it "if the attribute's value is not an hash, then that value will be simply cloned" do
          expect(subject.new(address: 'something').address).to eq('something')
        end

        it "if the attribute's value is an array, a new instance of that class will be initialized for each array entry" do
          posts = subject.new(posts: [{ body: 'post1' }, { body: 'post2' }]).posts

          expect(posts.length).to be(2)

          expect(posts[0]).to be_instance_of(Post)
          expect(posts[0].body).to eq('post1')

          expect(posts[1]).to be_instance_of(Post)
          expect(posts[1].body).to eq('post2')
        end

      end

      context "that is declared (in schema) as a date" do

        it "if the attribute's value is a valid date string" do
          dob = subject.new(dob: '2-2-2222').dob

          expect(dob).to be_instance_of(Date)
          expect(dob.day).to be(2)
          expect(dob.month).to be(2)
          expect(dob.year).to be(2222)
        end

        it "if the attribute's value is a valid date" do
          date_now = DateTime.now
          dob = subject.new(dob: date_now).dob

          expect(dob).to be_instance_of(DateTime)
          expect(dob).to eq(date_now)
        end

        it "if the attribute's value is an invalid date string, the returning value should be nil" do
          expect(subject.new(dob: '2s-2-2222').dob).to be_nil
        end

      end

      context "that is declared (in schema) as a datetime" do

        it "if the attribute's value is a valid datetime string" do
          date = subject.new(date: '2-2-2222 12:30').date

          expect(date).to be_instance_of(DateTime)
          expect(date.day).to be(2)
          expect(date.month).to be(2)
          expect(date.year).to be(2222)
          expect(date.hour).to be(12)
          expect(date.min).to be(30)
        end

        it "if the attribute's value is a valid datetime" do
          date_now = DateTime.now
          date = subject.new(date: date_now).date

          expect(date).to be_instance_of(DateTime)
          expect(date).to eq(date_now)
        end

        it "if the attribute's value is an invalid datetime string, the returning value should be nil" do
          expect(subject.new(date: '2s-2-2222').date).to be_nil
        end

      end

    end

  end

end
