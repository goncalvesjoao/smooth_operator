module UserWithAddressAndPosts
  
  class Father < SmoothOperator::Base

    schema(
      posts: Post,
      address: Address
    )

  end

  class Son < Father

    self.table_name = 'users'

    self.endpoint = 'http://localhost:4567/'

    schema(
      age: :int,
      dob: :date,
      manager: :bool
    )

  end
  
end
