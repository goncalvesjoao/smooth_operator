module SmoothOperator
  class ProtocolHandler
  
    include HTTParty
    format :json

    def self.get_options(options)
    	{ query: options }
    end

    def self.post_options(options)
    	{ body: options }
    end

    def self.put_options(options)
    	{ body: options }
    end

    def self.delete_options(options)
    	{ body: options }
    end
    
  end
end
