class Post < SmoothOperator::Base

  self.endpoint_user = 'admin'

  self.endpoint_pass = 'admin'

  self.endpoint = 'http://localhost:4567/'

  has_many :comments

  belongs_to :address

end
