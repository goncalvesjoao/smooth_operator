module User

  class Base < SmoothOperator::Base

    # self.table_name = 'users'
    self.table_name = 'patient_medicines'

    self.endpoint = 'http://localhost:3000/api/v0/'

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

      schema(
        age: :int,
        dob: :date,
        manager: :bool
      )

    end
    
  end

end
