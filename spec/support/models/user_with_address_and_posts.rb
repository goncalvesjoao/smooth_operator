module UserWithAddressAndPosts
  
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
