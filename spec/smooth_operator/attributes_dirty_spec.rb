require "spec_helper"

describe SmoothOperator::Attributes::Dirty do

  subject { UserWithAddressAndPosts::DirtyAttributes.new(attributes_for(:user_with_address_and_posts)) }

  context "when no changes are made to an attribute" do
    it "checking if that attribute is changed, should return false" do
      expect(subject.first_name_changed?).to be false
    end

    it "checking that attribute past value, should its original value" do
      expect(subject.first_name_was).to eq('John')
    end
  end

  context "when there are changes made to an attribute" do
    before { subject.first_name = 'nhoJ' }

    it "checking if that attribute is changed, should return true" do
      expect(subject.first_name_changed?).to be true
    end

    it "checking that attribute past value, should its original value" do
      expect(subject.first_name_was).to eq('John')
    end

    context "when there are changes to the changes made to an attribute" do
      before { subject.first_name = 'no_name' }

      it "checking if that attribute is changed, should return true" do
        expect(subject.first_name_changed?).to be true
      end

      it "checking that attribute past value, should its first original value" do
        expect(subject.first_name_was).to eq('John')
      end
    end
  end

  context "when there are changes made to a nested object" do
    before { subject.address.street = 'my street' }

    it "checking if the nested object as changed, should return false" do
      expect(subject.address_changed?).to be false
    end

    it "checking if the nested object's attribute as changed, should return true" do
      expect(subject.address.street_changed?).to be true
    end
  end

end
