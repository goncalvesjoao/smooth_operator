require "spec_helper"

describe SmoothOperator::Delegation do

  describe "#respond_to?" do
    let(:initial_attributes_keys) { attributes_for(:user).keys }

    context "when there is no declared schema" do
      subject { UserWithMyMethod.new(attributes_for(:user)) }

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
      subject { UserWithAddressAndPosts::Son.new(attributes_for(:user)) }
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
    subject { UserWithAddressAndPosts::Son.new(attributes_for(:user)) }

    context "when calling a method that matches the initialized attributes" do
      it 'it should return the value of that same attribute' do
        attributes_for(:user).each { |key, value| expect(subject.send(key)).to eq(value) }
      end
    end

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

    context "when no changes are made to an attribute" do
      it "checking it that attribute is changed, should return false" do
        expect(subject.first_name_changed?).to be false
      end

      it "checking that attribute past value, should its original value" do
        expect(subject.first_name_was).to eq('John')
      end
    end

    context "when there are changes made to an attribute" do
      before { subject.first_name = 'nhoJ' }

      it "checking it that attribute is changed, should return true" do
        expect(subject.first_name_changed?).to be true
      end

      it "checking that attribute past value, should its original value" do
        expect(subject.first_name_was).to eq('John')
      end

      context "when there are changes to the changes made to an attribute" do
        before { subject.first_name = 'no_name' }

        it "checking it that attribute is changed, should return true" do
          expect(subject.first_name_changed?).to be true
        end

        it "checking that attribute past value, should its first original value" do
          expect(subject.first_name_was).to eq('John')
        end
      end
    end

  end

end
