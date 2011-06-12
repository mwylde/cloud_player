require 'rubybits'
module CloudPlayer
  # Helper that eases use of the wire protocol
  class Client
    # Searches for the specified string
    def search string
      
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
    [:play_trk, :queue_add, :queue_del, :alb_detail,
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
                       :cmd => Protocol.const_get("#{cc.upcase}_CMD"),
                       :len => data.size,
                       :data => data)
      send_string p, block
    end

    def send_string p, block
      id = p.id
      @requests[id] = block
      send_data p.to_s
    end

    def new_id
      rand(2**16)
    end
  end
  
  # Spec for communication protocol between clients/servers
  class Protocol < RubyBits::Structure
    PLAY_CMD       = 0
    PAUSE_CMD      = 1
    PREV_CMD       = 14
    NEXT_CMD       = 15
    PLAY_TRK_CMD   = 2
    QUEUE_LIST_CMD = 3
    QUEUE_ADD_CMD  = 4
    QUEUE_DEL_CMD  = 5
    QUEUE_CLR_CMD  = 6
    ALB_LIST_CMD   = 7
    TRK_LIST_CMD   = 8
    PLST_LIST_CMD  = 9
    ALB_DETAIL_CMD = 10
    TRK_DETAIL_CMD = 11
    PLST_DETAIL_CMD= 12
    SEARCH_CMD     = 13

    unsigned :id,     16,  "ID number for request, which is resent with results"
    unsigned :cmd,    8,   "Command ID, specified as constants in structure.rb"
    unsigned :len,    16,  "Length of data in bytes"
    variable :data,        "Data, which is command-specific", :length => :len
    unsigned :checksum,8,  "Checksum byte = (sum of the previous bytes) & 255"

    checksum :checksum do |bytes|
      bytes[0..-2].reduce(:+) & 255
    end
  end
end
