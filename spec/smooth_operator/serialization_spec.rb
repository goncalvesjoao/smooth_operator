require "spec_helper"

describe SmoothOperator::Serialization do

  describe "#to_json" do
    let(:filtered_response) { { id: 1, first_name: 'first' } }
    let(:initializer_hash) { { id: 1, first_name: 'first', last_name: 'last', admin: true } }
    let(:smooth_operator_instance) { Post.new(initializer_hash) }

    context "when there are no changes to attributes's white and black list" do
      it 'it should return all attributes' do
        expect(smooth_operator_instance.to_json).to eq(initializer_hash.to_json)
      end
    end

    context "when there are changes to attributes's white list" do
      subject(:white_listed_instance) { PostWhiteListed::Son.new(initializer_hash) }

      it 'it should return only the white listed' do
        expect(white_listed_instance.to_json).to eq(filtered_response.to_json)
      end
    end

    context "when there are changes to attributes's black list" do
      subject(:black_listed_instance) { PostBlackListed::Son.new(initializer_hash) }

      it 'it should not return the black listed' do
        expect(black_listed_instance.to_json).to eq(filtered_response.to_json)
      end
    end

    context "when option 'only' is introduced" do
      subject(:options_with_only) { { only: [:id, :first_name] } }

      it 'it should only return the filtered options' do
        expect(smooth_operator_instance.to_json(options_with_only)).to eq(filtered_response.to_json)
      end
    end

    context "when option 'except' is introduced" do
      subject(:options_with_except) { { except: [:last_name, :admin] } }

      it 'it should return all fields except for the filtered options' do
        expect(smooth_operator_instance.to_json(options_with_except)).to eq(filtered_response.to_json)
      end
    end

    context "when option 'methods' is introduced" do
      subject(:options_with_method) { { methods: :method1 } }
      let(:attributes_with_methods) { initializer_hash.merge(method1: 'method1') }

      it 'it should return all fields including the expected method and its returning value' do
        expect(smooth_operator_instance.to_json(options_with_method)).to eq(attributes_with_methods.to_json)
      end
    end

  end

end
