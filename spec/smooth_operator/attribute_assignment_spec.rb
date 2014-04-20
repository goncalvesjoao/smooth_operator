require "spec_helper"

describe SmoothOperator::AttributeAssignment do

  describe "#assign_attributes" do

    context "when there is no declared schema" do
      subject(:user) { User::Base.new(attributes_for(:user)) }
      let(:expected_internal_data) { SmoothOperator::Helpers.stringify_keys(attributes_for(:user)) }

      it "it should populate 'internal_data' with unaltered duplicate data from the received hash" do
        expect(user.internal_data).to eq(expected_internal_data)
      end

      it "it should populate 'known_attributes' with the keys of the received hash" do
        expect(user.known_attributes.to_a).to match_array(expected_internal_data.keys)
      end

    end

    context "when there is a known schema and the received hash has an attribute" do

      context "that is declared (in schema) as an integer" do

        it "when the attributes's value is '1', should be converted to 1" do
          expect(User::WithAddressAndPosts::Son.new(age: '1').age).to be(1)
        end

        it "when the attributes's value is '-1', should be converted to -1" do
          expect(User::WithAddressAndPosts::Son.new(age: '-1').age).to be(-1)
        end

        it "when the attributes's value is 's-10s', should be converted to -10" do
          expect(User::WithAddressAndPosts::Son.new(age: 's-10s').age).to be(-10)
        end

        it "when the attributes's value is ' 10s', should be converted to 10" do
          expect(User::WithAddressAndPosts::Son.new(age: ' 10s').age).to be(10)
        end

        it "when the attributes's value is 123, should be converted to 123" do
          expect(User::WithAddressAndPosts::Son.new(age: 123).age).to be(123)
        end

        it "when the attributes's value is -5, should be converted to -5" do
          expect(User::WithAddressAndPosts::Son.new(age: -5).age).to be(-5)
        end

      end

      context "that is declared (in schema) as an boolean" do

        it "when the attributes's value is true, should be converted to true" do
          expect(User::WithAddressAndPosts::Son.new(manager: true).manager).to be(true)
        end

        it "when the attributes's value is false, should be converted to false" do
          expect(User::WithAddressAndPosts::Son.new(manager: false).manager).to be(false)
        end

        it "when the attributes's value is 'true', should be converted to true" do
          expect(User::WithAddressAndPosts::Son.new(manager: 'true').manager).to be(true)
        end

        it "when the attributes's value is 'false', should be converted to false" do
          expect(User::WithAddressAndPosts::Son.new(manager: 'false').manager).to be(false)
        end
        
        it "when the attributes's value is '1', should be converted to true" do
          expect(User::WithAddressAndPosts::Son.new(manager: '1').manager).to be(true)
        end

        it "when the attributes's value is '0', should be converted to false" do
          expect(User::WithAddressAndPosts::Son.new(manager: '0').manager).to be(false)
        end

        it "when the attributes's value is '', should be converted to nil" do
          expect(User::WithAddressAndPosts::Son.new(manager: '').manager).to be_nil
        end

        it "when the attributes's value is 'something', should be converted to nil" do
          expect(User::WithAddressAndPosts::Son.new(manager: 'something').manager).to be_nil
        end

      end
      
      context "that is declared (in schema) as an existing class" do

        it "if the attribute's value is an hash a new instance of that class will be initialized with that hash" do
          address = User::WithAddressAndPosts::Son.new(address: { street: 'something' }).address

          expect(address).to be_instance_of(Address)
          expect(address.street).to eq('something')
        end

        it "if the attribute's value is not an hash, then that value will be simply cloned" do
          expect(User::WithAddressAndPosts::Son.new(address: 'something').address).to eq('something')
        end

        it "if the attribute's value is an array, a new instance of that class will be initialized for each array entry" do
          posts = User::WithAddressAndPosts::Son.new(posts: [{ body: 'post1' }, { body: 'post2' }]).posts
          
          expect(posts.length).to be(2)

          expect(posts[0]).to be_instance_of(Post)
          expect(posts[0].body).to eq('post1')
          
          expect(posts[1]).to be_instance_of(Post)
          expect(posts[1].body).to eq('post2')
        end

      end

    end

  end

end
