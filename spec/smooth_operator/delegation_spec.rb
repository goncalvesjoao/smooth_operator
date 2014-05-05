require "spec_helper"

describe SmoothOperator::Delegation do

  describe "#respond_to?" do
    let(:initial_attributes_keys) { attributes_for(:user_with_address_and_posts).keys }

    context "when there is no declared schema" do
      subject { UserWithAddressAndPosts::UserWithMyMethod.new(attributes_for(:user_with_address_and_posts)) }

      it 'it should return true for every attribute used uppon initialization' do
        initial_attributes_keys.each do |attribute|
          expect(subject.respond_to?(attribute)).to eq(true)
        end
      end

      it 'it should return false in for unknown attributes/methods' do
        expect(subject.respond_to?(:unknown)).to eq(false)
      end

      it 'it should return true for any existing method' do
        expect(subject.respond_to?(:my_method)).to eq(true)
      end
    end

    context "when there is a known schema" do
      subject { UserWithAddressAndPosts::Son.new(attributes_for(:user_with_address_and_posts)) }
      let(:known_schema_attributes) { ["posts", "address", "manager"] }

      it 'it should return true for every attribute used uppon initialization' do
        initial_attributes_keys.each do |attribute|
          expect(subject.respond_to?(attribute)).to eq(true)
        end
      end

      it 'it should return true for known schema attributes' do
        known_schema_attributes.each do |attribute|
          expect(subject.respond_to?(attribute)).to eq(true)
        end
      end
    end

  end

  describe "#method_missing" do
    
    context "when calling a method that matches the initialized attributes" do
      subject { User::Base.new(attributes_for(:user)) }

      it 'it should return the value of that same attribute' do
        attributes_for(:user).each do |key, value|
          expect(subject.send(key)).to eq(value)
        end
      end
    end


    subject { UserWithAddressAndPosts::Son.new(attributes_for(:user_with_address_and_posts)) }

    context "when calling a method that doesn't match the initialized attributes but matches the schema" do
      it 'it should return nil' do
        expect(subject.manager).to eq(nil)
      end
    end

    context "when calling a method that doesn't match either the schema nor the initialized attributes" do
      it 'it should raise NoMethodError' do
        expect { subject.unknown_method }.to raise_error NoMethodError
      end
    end

    context "when setting a new attribute not declared on schema" do
      before { subject.unknown_attribute = 'unknown_value' }

      it "#known_attributes must reflect that new attribute" do
        expect(subject.known_attributes.to_a).to include('unknown_attribute')
      end
      
      it "#respond_to? must return true" do
        expect(subject.respond_to?(:unknown_attribute)).to eq(true)
      end
      
      it "calling a method with the same name must return that attribute's value" do
        expect(subject.unknown_attribute).to eq('unknown_value')
      end
    end

  end

end
