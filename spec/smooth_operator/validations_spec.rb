require "spec_helper"

describe SmoothOperator::Validations do
  subject { User::Base.new(attributes_for(:user)) }

  describe "#valid?" do
    context "when executing a persistence method, and the server response has a hash with the key 'errors'" do
      before { subject.save('send_error') }

      it "it should return false" do
        expect(subject.valid?).to be false
      end
    end

    context "when executing a persistence method, and the server response does NOT have a hash with the key 'errors'" do
      before { subject.save }

      it "it should return true" do
        expect(subject.valid?).to be true
      end
    end
  end

  describe "#invalid?" do
    context "when executing a persistence method, and the server response has a hash with the key 'errors'" do
      before { subject.save('send_error') }

      it "it should return true" do
        expect(subject.invalid?).to be true
      end
    end

    context "when executing a persistence method, and the server response does NOT have a hash with the key 'errors'" do
      before { subject.save }

      it "it should return false" do
        expect(subject.invalid?).to be false
      end
    end
  end

end
