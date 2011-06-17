module CloudPlayer
  # Spec for communication protocol between clients/servers
  class Protocol < RubyBits::Structure
    PLAY_CMD        = 0
    PAUSE_CMD       = 1
    PREV_CMD        = 2
    NEXT_CMD        = 3
    PLAY_ITEM_CMD   = 4
    QUEUE_LIST_CMD  = 5
    QUEUE_ADD_CMD   = 6
    QUEUE_DEL_CMD   = 7
    QUEUE_CLR_CMD   = 8
    ALB_LIST_CMD    = 9
    TRK_LIST_CMD    = 10
    PLST_LIST_CMD   = 11
    ITEM_DETAIL_CMD = 12
    SEARCH_CMD      = 13

    unsigned :id,     16,  "ID number for request, which is resent with results"
    unsigned :cmd,    8,   "Command ID, specified as constants in structure.rb"
    unsigned :len,    32,  "Length of data in bytes"
    variable :data,        "Data", :length => :len, :unit => :byte
    unsigned :checksum,8,  "Checksum byte = (sum of the previous bytes) & 255"

    checksum :checksum do |bytes|
      bytes[0..-2].reduce(:+) & 255
    end
  end
end
