require "spec_helper"

describe SmoothOperator::Delegation do

  describe "#respond_to?" do
    subject(:user) { User::Base.new(attributes_for(:user)) }

    context "when there is no declared schema" do
      let(:initial_attributes_keys) { attributes_for(:user).keys.map(&:to_s) }

      it 'it should return true for every attribute used uppon initialization' do
        initial_attributes_keys.each do |attribute|
          expect(user.respond_to?(attribute)).to eq(true)
        end
      end
    end

  end

end
