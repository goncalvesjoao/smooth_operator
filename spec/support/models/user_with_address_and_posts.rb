module UserWithAddressAndPosts
  
  class Father < User

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
  
end
