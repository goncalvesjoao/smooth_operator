require "spec_helper"

describe SmoothOperator::Serialization do

  describe "#to_json" do
    
    subject { UserWithAddressAndPosts::Son.new(attributes_for(:user_with_address_and_posts)) }

    context "when there are no changes to attributes's white and black list" do
      it 'it should return all attributes' do
        expect(subject.to_hash).to eq(attributes_for(:user_with_address_and_posts))
      end
    end

    context "when there are changes to attributes's white list" do
      subject(:user_white_listed) { UserWithAddressAndPosts::UserWhiteListed::Son.new(attributes_for(:user_with_address_and_posts)) }

      it 'it should return only the white listed' do
        expect(user_white_listed.to_hash).to eq(attributes_for(:white_list))
      end
    end

    context "when there are changes to attributes's black list" do
      subject(:user_black_listed) { UserWithAddressAndPosts::UserBlackListed::Son.new(attributes_for(:user_with_address_and_posts)) }

      it 'it should not return the black listed' do
        expect(user_black_listed.to_hash).not_to include(attributes_for(:black_list))
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
