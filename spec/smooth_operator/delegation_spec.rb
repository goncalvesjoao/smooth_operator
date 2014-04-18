require "spec_helper"

describe SmoothOperator::Delegation do

  describe "#respond_to?" do

    context "when there is no declared schema" do
      subject(:user) { User::Base.new(attributes_for(:user)) }
      let(:initial_attributes_keys) { attributes_for(:user).keys }

      it 'it should return true for every attribute used uppon initialization' do
        initial_attributes_keys.each do |attribute|
          expect(user.respond_to?(attribute)).to eq(true)
        end
      end
    end

    context "when there is a known schema" do
      subject(:user) { User::WithAddressAndPosts::Son.new(attributes_for(:user)) }
      let(:initial_attribute_and_known_schema) { attributes_for(:user).keys | [:posts, :address, :manager] }

      it 'it should return true for every initialized attribute and known schema attributes' do
        initial_attribute_and_known_schema.each do |attribute|
          expect(user.respond_to?(attribute)).to eq(true)
        end
      end
    end

  end

  describe "#method_missing" do
    subject(:user) { User::WithAddressAndPosts::Son.new(attributes_for(:user)) }

    context "when calling a method that matches the initialized attributes" do
      it 'it should return the value of that same attribute' do
        expect(user.id).to eq(1)
      end
    end

    context "when calling a method that doesn't match the initialized attributes but matches the schema" do
      it 'it should return nil' do
        expect(user.manager).to eq(nil)
      end
    end

    context "when calling a method that doesn't match either the schema nor the initialized attributes" do
      it 'it should raise NoMethodError' do
        expect { user.unknown_method }.to raise_error NoMethodError
      end
    end

  end

end
