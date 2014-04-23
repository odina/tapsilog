module Palmade::Tapsilog
  class Protocol < EventMachine::Connection
    Ci = 'i'.freeze
    Rcolon = /:/
    MaxMessageLength = 8192

    LoggerClass = Palmade::Tapsilog::Server

    def post_init
      setup
    end

    def setup
      @length = nil
      @logchunk = ''
      @authenticated = nil
      @use_analogger_protocol = false
    end

    def receive_data(data)
      @logchunk << data
      process_data
    end

    protected

    def process_data
      return false if @logchunk.length < 7
      get_length if @length.nil?

      if @length and @logchunk.length > @length
        get_message
      end
    end

    def get_length
      l = @logchunk[0..3].unpack(Ci).first
      ck = @logchunk[4..7].unpack(Ci).first

      if l == ck and l < MaxMessageLength
        @length = l +7
        return true
      else
        peer = get_peername
        peer = (peer ? ::Socket.unpack_sockaddr_in(peer)[1] : 'UNK') rescue 'UNK'

        if l == ck
          LoggerClass.add_log([:default, $$.to_s, :error, "Max Length Exceeded from #{peer} -- #{l}/#{MaxMessageLength}"])
        else
          LoggerClass.add_log([:default, $$.to_s, :error, "Checksum failed from #{peer} -- #{l}/#{ck}"])
        end

        close_connection
        return false
      end
    end

    def get_message
      msg = @logchunk.slice!(0..@length).split(Rcolon, 5)

      unless @authenticated
        @authenticated = authenticate_message(msg)
      end

      if @authenticated
        msg[0] = nil
        msg.shift

        msg[0] = msg[0].to_s.gsub(/[^a-zA-Z0-9\-\_\.]\s/, '').strip

        unless @use_analogger_protocol
          tag_string, message = msg[3].split(':', 2)
          msg[3] = message
          msg[4] = Utils::query_string_to_hash(tag_string.to_s)
        end

        LoggerClass.add_log(msg)
        @length = nil
        process_data
      end
    end

    def authenticate_message(msg)
      return false if msg[3] != "authentication"

      if msg[4] == LoggerClass.key
        @use_analogger_protocol = true
        return true
      elsif msg[4].split(':', 2)[1] == LoggerClass.key
        return true
      else
        peer = get_peername
        peer = (peer ? ::Socket.unpack_sockaddr_in(peer)[1] : 'UNK') rescue 'UNK'

        LoggerClass.add_log([:default, $$.to_s, :error, "Invalid key from #{peer} -- #{msg[4]}"])
        close_connection
        return false
      end
    end

  end
end
