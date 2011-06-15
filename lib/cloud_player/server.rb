module CloudPlayer
  class Server
    def initialize options
      trap "INT" do
        puts "Received signal, dying..."
        exit!
      end

      @options = options
      @options[:user] ||= "wyldeone@gmail.com"
      @options[:password] ||= "helloasdf1"
      @session = Amazon::Session.new(@options[:user], @options[:password])
      begin
        @session.login
        puts "Logged in to Amazon"
      rescue AuthenticationError
        puts "Failed to log in to Amazon".foreground(:red)
        exit
      end
      @library = Amazon::Library.new(@session)
      #TODO: Load other stuff
      @library.load_albums
      puts "Loaded stuff"
      @queue = []
    end

    def run
      ServerConnection.instance_variable_set(:@server, self)
      EM.run {
        puts "Started server on #{@options[:port]}"
        EM.start_server "127.0.0.1", @options[:port], ServerConnection
      }
    end

    def play
    end

    def pause
    end

    def prev
    end

    def _next_
    end

    def play_item id
      @queue += tracks_for_id(id)
      _next_
    end

    def queue_list
      @queue.collect{|item| item.id}.join(",")
    end

    def queue_add id
      @queue = tracks_for_id(id) + @queue
      true
    end

    def queue_delete id
      raise "Not implemented"
    end

    def queue_clear
      @queue.clear
    end

    def album_list
      raise "Not implemented"
    end

    def playlist_list
      raise "Not implemented"
    end

    def item_detail id
      Library.find(id).serialize
    end

    def search s
      @library.search(s).join(",")
    end

    def tracks_for_item item
      case item
      when Amazon::Track
        [item]
      when Amazon::Album
        tracks = album.tracks_for_album(@library.find(id))
        # we reverse because @queue is a...queue and tracks are popped
        # from the back, and we want track 1 to be popped first
        tracks.sort_by{|t| t.track_num ? t.track_num.to_i : 0}.reverse
      when Amazon::Playlist
        raise "Not implemented"
      else
        raise "Unhandled item"
      end
    end

    def tracks_for_id id
      tracks_for_item(@library.find(id))
    end
  end


  # EventMachine Connection subclass which handles the actual business
  # of talking to clients.
  class ServerConnection < EM::Connection
    def initialize
      @buffer = ""
      @server = self.class.instance_variable_get(:@server)
    end

    def receive_data data
      # puts "Got data: #{data.bytes.to_a.collect{|x| x.to_s(16)}.join(" ")}"
      @buffer << data
      resps, @buffer = Protocol.parse(@buffer)
      resps.each{|resp|
        handle resp
      }
    end

    def respond p, data
      resp = Protocol.new(:id => p.id,
                          :cmd => p.cmd,
                          :len => data.size,
                          :data => data).to_s
      send_data resp
    end

    def handle p
      puts "Handling: #{p.data}"
      case p.cmd
      when Protocol::PLAY_CMD
        respond p, @server.play
      when Protocol::PAUSE_CMD
        respond p, @server.pause
      when Protocol::PREV_CMD
        respond p, @server.prev
      when Protocol::NEXT_CMD
        respond p, @server._next_
      when Protocol::PLAY_ITEM_CMD
        respond p, @server.play_item(p.data)
      when Protocol::QUEUE_LIST_CMD
        respond p, @server.queue_list
      when Protocol::QUEUE_ADD_CMD
        respond p, @server.queue_add(p.data)
      when Protocol::QUEUE_DEL_CMD
        respond p, @server.queue_delete(p.data)
      when Protocol::QUEUE_CLR_CMD
        respond p, @server.queue_clear
      when Protocol::ALB_LIST_CMD
        respond p, @server.album_list
      when Protocol::TRK_LIST_CMD
        respond p, @server.track_list
      when Protocol::PLST_LIST_CMD
        respond p, @server.playlist_list
      when Protocol::ALB_DETAIL_CMD
        respond p, @server.album_detail(p.data)
      when Protocol::TRK_DETAIL_CMD
        respond p, @server.track_detail(p.data)
      when Protocol::PLST_DETAIL_CMD
        respond p, @server.playlist_detail(p.data)
      when Protocol::SEARCH_CMD
        respond p, @server.search(p.data)
      else
        error p, "Unknown command #{p.cmd}"
      end
    end
  end
end
