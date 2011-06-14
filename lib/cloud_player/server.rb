module CloudPlayer
  class Server
    def initialize options
      @options = options
      @session = Amazon::Session.new(@options[:user], @options[:password])
      begin
        @session.login
        puts "Logged in to Amazon"
      rescue AuthenticationError
        puts "Failed to log in to Amazon".foreground(:red)
        exit
      end
      @library = Amazon::Library.new(@session)
      @library.load_everything
      @queue = []
    end

    def run
      
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

    def album_detail id
      raise "Not implemented"
    end

    def track_detail id
      raise "Not implemented"
    end

    def playlist_detail id
      raise "Not implemented"
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
  class ServerConnection < Connection
    def initialize server
      @buffer = ""
      @server = server
    end
    
    def receive_data data
      @buffer << data
      resps, @buffer = Protocol.parser(@buffer)
      resps.each{|resp|
        handle resp
      }
    end

    def handle p
      case p.cmd
      when PLAY_CMD
        respond p, @server.play
      when PAUSE_CMD
        respond p, @server.pause
      when PREV_CMD
        respond p, @server.prev
      when NEXT_CMD
        respond p, @server._next_
      when PLAY_ITEM_CMD
        respond p, @server.play_item(p.data)
      when QUEUE_LIST_CMD
        respond p, @server.queue_list
      when QUEUE_ADD_CMD
        respond p, @server.queue_add(p.data)
      when QUEUE_DEL_CMD
        respond p, @server.queue_delete(p.data)
      when QUEUE_CLR_CMD
        respond p, @server.queue_clear
      when ALB_LIST_CMD
        respond p, @server.album_list
      when TRK_LIST_CMD
        respond p, @server.track_list
      when PLST_LIST_CMD
        respond p, @server.playlist_list
      when ALB_DETAIL_CMD
        respond p, @server.album_detail(p.data)
      when TRK_DETAIL_CMD
        respond p, @server.track_detail(p.data)
      when PLST_DETAIL_CMD
        respond p, @server.playlist_detail(p.data)
      when SEARCH_CMD
        respond p, @server.search(p.data)
      else
        error p, "Unknown command #{p.cmd}"
      end
    end
  end
end
