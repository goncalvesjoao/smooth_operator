class Post < SmoothOperator::Base

  self.turn_unknown_hash_to_open_struct = false
  
  self.endpoint = 'http://localhost:3000/api/v0'

end
