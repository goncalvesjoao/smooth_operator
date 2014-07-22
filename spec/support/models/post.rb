class Post < SmoothOperator::Base

  options endpoint_user: 'admin',
          endpoint_pass: 'admin',
          rails_serialization: true,
          endpoint: 'http://localhost:4567/',
          unknown_hash_class: SmoothOperator::OpenStruct

  has_many :comments#, rails_serialization: true

  belongs_to :address#, rails_serialization: true

end
