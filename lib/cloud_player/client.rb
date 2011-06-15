module CloudPlayer
  # Helper that eases use of the wire protocol
  class Client < EM::Connection
    def initialize
      @buffer = ""
      @requests = {}
    end

    def self.connect(options = {})
      EM.connect('127.0.0.1', options[:port], self) {|c|
        # According to the docs, we will get here AFTER post_init is called.
        c.instance_eval {@options = options}
      }
    end

    # These methods all map to commands that take no data
    [:play, :pause, :prev, :next, :queue_list,
     :queue_clr, :alb_list, :trk_list, :plst_list].each{|cc|
      define_method cc do |&block|
        do_command cc, "", &block
      end
    }

    # These methods all take one parameter which is converted directly
    # to data in the remote request
    [:play_item, :queue_add, :queue_del, :alb_detail,
     :trk_detail, :plst_detail, :search].each{|cc|
      define_method cc do |param, &block|
        do_command cc, param, &block
      end
    }

    def do_command cmd, param, &block
      data = case param
             when String then param
             when Fixnum
               s = []
               i = param
               while i != 0
                 s << (i & 255)
                 i = (i - s[-1])/256
               end
               s.pack("c*")
             else
               raise "Only string and fixnum params supported."
             end
      p = Protocol.new(:id => new_id,
                       :cmd => Protocol.const_get("#{cmd.upcase}_CMD"),
                       :len => data.size,
                       :data => data)
      send_protocol p, block
    end

    def send_protocol p, block
      @requests[p.id] = block
      send_data p.to_s
    end

    def new_id
      65536.times{|x| return x unless @requests[x]}
      raise "Too many requests outstanding"
    end

    def receive_data data
      # puts "Got data: #{data.bytes.to_a.collect{|x| x.to_s(16)}.join(" ")}"
      @buffer << data
      resps, @buffer = Protocol.parse(@buffer)
      resps.each{|resp|
        @requests[resp.id].call(resp.data)
        @requests.delete(resp.id)
      }
    end
  end
end
