module SmoothOperator
  
  module FinderMethods

    def all(data = {}, options = {})
      find(:all, data, options)
    end

    def find(relative_path, data = {}, options = {})
      relative_path = '' if relative_path == :all

      get(relative_path, data, options).tap do |remote_call|
        remote_call.object_class = self
      end
    end

  end
  
end
