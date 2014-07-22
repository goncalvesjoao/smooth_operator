module UserWithAddressAndPosts

  class Father < User::Base

    options resource_name: 'user'

    schema(
      posts: Post,
      address: Address
    )

  end

  class Son < Father

    schema(
      age: :int,
      dob: :date,
      price: :float,
      manager: :bool,
      date: :datetime,
      complex_field: nil,
      first_name: :string
    )

  end

  class SoftBehaviour < Son

    options strict_behaviour: false

  end

  class WithPatch < Son

    options update_http_verb: 'patch'

  end


  module UserBlackListed

    class Father < ::UserWithAddressAndPosts::Son

      attributes_black_list_add "last_name"

    end

    class Son < Father

      attributes_black_list_add :admin

    end

  end

  module UserWhiteListed

    class Father < ::UserWithAddressAndPosts::Son

      attributes_white_list_add "id"

    end

    class Son < Father

      attributes_white_list_add :first_name

    end

  end

  class UserWithMyMethod < UserWithAddressAndPosts::Son

    def my_method
      'my_method'
    end

  end

end
