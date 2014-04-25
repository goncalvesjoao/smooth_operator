require "spec_helper"

describe SmoothOperator::Serialization do

  describe "#attributes" do
    subject { UserWithAddressAndPosts::Son.new(attributes_for(:user_with_address_and_posts)) }

    context "when there are changes to nested objects" do
      before { subject.address.street = 'new street' }

      it "should refect those changes" do
        new_attributes = attributes_for(:user_with_address_and_posts)
        new_attributes[:address][:street] = 'new street'
        
        expect(subject.attributes).to eq(new_attributes)
      end
    end
  end

  describe "#to_hash" do
    subject { UserWithAddressAndPosts::Son.new(attributes_for(:user_with_address_and_posts)) }

    context "when no options are given" do
      it 'it should return all attributes' do
        expect(subject.to_hash).to eq(attributes_for(:user_with_address_and_posts))
      end
    end

    context "when option 'only' is introduced" do
      let(:options_with_only) { { only: [:id, :first_name] } }

      it 'it should only return the filtered options' do
        expect(subject.to_hash(options_with_only)).to eq(attributes_for(:white_list))
      end
    end

    context "when option 'except' is introduced" do
      let(:options_with_except) { { except: [:last_name, :admin] } }

      it 'it should return all fields except for the filtered options' do
        expect(subject.to_hash(options_with_except)).not_to include(attributes_for(:black_list))
      end
    end

    context "when option 'methods' is introduced" do
      let(:options_with_method) { { methods: :my_method } }
      subject(:user_with_my_method) { UserWithAddressAndPosts::UserWithMyMethod.new(attributes_for(:user_with_address_and_posts)) }

      it 'it should return all fields including the expected method and its returning value' do
        expect(user_with_my_method.to_hash(options_with_method)).to eq(attributes_for(:user_with_my_method))
      end
    end

  end

end
