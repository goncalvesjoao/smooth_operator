module UserWhiteListed
  
  class Father < SmoothOperator::Base

    attributes_white_list_add "id"

  end

  class Son < Father

    attributes_white_list_add :first_name

  end

end
