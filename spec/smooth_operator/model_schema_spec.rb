require "spec_helper"

describe SmoothOperator::ModelSchema do

  describe "#known_attributes" do

    context "when there is no declared schema" do
      subject(:user) { User::Base.new(attributes_for(:user)) }
      let(:initial_attributes_keys) { attributes_for(:user).keys.map(&:to_s) }

      it 'it should reflect the attributes used uppon initialization' do
        expect(user.known_attributes.to_a).to match_array(initial_attributes_keys)
      end
    end

    context "when there is a known schema" do
      subject(:user) { User::WithAddressAndPosts::Son.new(attributes_for(:user)) }
      let(:initial_attribute_and_known_schema) { attributes_for(:user).keys.map(&:to_s) | ["posts", "address", "manager"] }

      it 'it should reflect the initialized attributes and known schema attributes' do
        expect(user.known_attributes.to_a).to match_array(initial_attribute_and_known_schema)
      end
    end

  end

end
