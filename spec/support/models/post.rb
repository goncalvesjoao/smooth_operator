class Post < SmoothOperator::Base

  self.endpoint_user = 'admin'

  self.endpoint_pass = 'admin'

  self.endpoint = 'http://localhost:4567/'

  self.rails_serialization = true

  has_many :comments#, rails_serialization: true

  belongs_to :address#, rails_serialization: true

end
