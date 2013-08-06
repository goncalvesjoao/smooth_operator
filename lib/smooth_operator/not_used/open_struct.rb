module SmoothOperator
  module OpenStruct

    extend self # extends the module Class with its instance methods and
                # makes it possible do 'SmoothOperator::OpenStruct.new'

    def new(attributes = {})
      ::OpenStruct.new(attributes).extend(SmoothOperator::OpenStruct)
    end

    def to_hash
      @table
    end

  end
end
