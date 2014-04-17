module User

  class Base < SmoothOperator::Base

    endpoint = 'http://localhost:3000/api/v0/patient_medicines/'

  end

  module BlackListed
    
    class Father < SmoothOperator::Base

      attributes_black_list_add "last_name"

    end

    class Son < Father

      attributes_black_list_add :admin

    end

  end

  module WhiteListed
    
    class Father < SmoothOperator::Base

      attributes_white_list_add "id"

    end

    class Son < Father

      attributes_white_list_add :first_name

    end

  end

  class WithMyMethod < SmoothOperator::Base

    def my_method
      'my_method'
    end

  end

  module WithAddressAndPosts
    
    class Father < SmoothOperator::Base

      schema(
        posts: Post,
        address: Address
      )

    end

    class Son < Father

      schema manager: :bool

    end
    
  end

end
