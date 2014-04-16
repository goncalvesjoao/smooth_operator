class Post < SmoothOperator::Base

  self.endpoint = 'http://localhost:3000/api/v0/patient_medicines/'

  def method1
    'method1'
  end

end
