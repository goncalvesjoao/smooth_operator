require "spec_helper"

describe SmoothOperator::ResourceName do

  describe "#known_attributes" do
    let(:initial_attributes_keys) { attributes_for(:user).keys.map(&:to_s) }

    context "when there is no declared schema" do
      subject { User::Base.new(attributes_for(:user)) }

      it 'it should reflect the attributes used uppon initialization' do
        expect(subject.known_attributes.to_a).to match_array(initial_attributes_keys)
      end
    end

    context "when there is a known schema" do
      subject { UserWithAddressAndPosts::Son.new(attributes_for(:user)) }
      let(:known_schema_attributes) { ["posts", "address", "manager"] }

      it 'it should reflect the attributes used uppon initialization' do
        expect(subject.known_attributes.to_a).to include(*initial_attributes_keys)
      end

      it 'it should reflect the known schema attributes' do
        expect(subject.known_attributes.to_a).to include(*known_schema_attributes)
      end
    end

  end

end
