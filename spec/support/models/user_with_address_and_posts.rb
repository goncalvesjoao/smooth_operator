module UserWithAddressAndPosts
  
  class Father < User::Base

    schema(
      posts: Post,
      address: Address
    )

  end

  class Son < Father

    self.table_name = 'users'

    schema(
      age: :int,
      dob: :date,
      manager: :bool
    )

  end

  class WithPatch < Son

    self.table_name = 'users'

    self.save_http_verb = :patch

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

  class DirtyAttributes < UserWithAddressAndPosts::Son

    self.dirty_attributes

    self.unknown_hash_class = SmoothOperator::OpenStruct::Dirty

  end

end
