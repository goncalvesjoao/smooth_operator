require "spec_helper"

describe SmoothOperator::ModelSchema do

  describe "#known_attributes" do
    subject(:user) { User::Base.new(attributes_for(:user)) }

    context "when there is no declared schema" do
      let(:initial_attributes_keys) { attributes_for(:user).keys.map(&:to_s) }

      it 'it should reflect the attributes used uppon initialization' do
        expect(user.known_attributes).to eq(initial_attributes_keys)
      end
    end

  end

end
