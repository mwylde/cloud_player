module CloudPlayer
  class Server
    def initialize options
      @options = options
    end

    def run
      
    end
  end

  
  # EventMachine Connection subclass which handles the actual business
  # of talking to clients.
  class ServerConnection < Connection
    
    def receive_data data
      
    end
  end
end
