module UserBlackListed
    
  class Father < SmoothOperator::Base

    attributes_black_list_add "last_name"

  end

  class Son < Father

    attributes_black_list_add :admin

  end

end
