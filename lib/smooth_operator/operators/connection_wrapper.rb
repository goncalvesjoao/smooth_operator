module SmoothOperator
  class ConnectionWrapper

    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end

    def run
      connection.run
    end

  end
end
