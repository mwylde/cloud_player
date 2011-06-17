module CloudPlayer
  class Runner < Thor

    ######## SERVER ##########
    desc "server", "Starts the cloud_player server"
    long_desc <<-D
      Server starts the cloud_player server, which will wait on a socket for
      commands from a client. The server is primarily responsible for playing
      music and managing a playlist.
    D
    method_option :daemonize, :default => false,  :desc => "Causes the server to fork into the background.", :aliases => "-d"
    method_option :port, :default => PORT, :desc => "The server will bind to the specified port.", :aliases => "-p"
    def server
      Server.new(:daemonize => !!options.daemonize, :port => options.port).run
    end

    ######## SEARCH ##########
    desc "search", "Searches your library for the given string"
    long_desc <<-D
      Connects to a running server (which must have already been started) and
      searches its library for the string provided.
    D
    method_option :in, :default => "all", :type => :string, :desc => "Restricts search to a particular object, which can be album, song, playlist or all", :aliases => "-i"
    method_option :port, :default => PORT, :desc => "The port that the server's running on.", :aliases => "-p"
    def search string
      EM.run do
        client = Client.connect(:port => options.port)
        client.search(string){|json|
          data = JSON.load(json)
          data.each_with_index{|id, i|
            item = Amazon::Library.unserialize_obj(id)
            puts "#{i}. #{item.albumName} - #{item.title}" if item
          }
          client.close_connection
          EM.stop
        }
      end
    end

    ######## VERSION ##########
    desc "version", "Prints version information"
    def version
      puts "CloudPlayer version #{CloudPlayer::VERSION}"
    end
    map %w(-v --version) => :version

  end
end
