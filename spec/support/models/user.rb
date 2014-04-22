class User < SmoothOperator::Base

  self.table_name = 'invoices'

  self.endpoint = 'http://localhost:3000/v0/'

end
