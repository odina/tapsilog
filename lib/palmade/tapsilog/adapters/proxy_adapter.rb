module Palmade::Tapsilog::Adapters
  class ProxyAdapter < BaseAdapter

    def initialize(config)
      super(config)
    end

    def write(log_message)
      service = log_message[1]
      instance_key = log_message[2]
      severity = log_message[3]
      message = log_message[4]
      tags = log_message[5]

      conn.log(service, instance_key, severity, message, tags)
    end

    def flush
      conn.flush
    end

    def close
      conn.close
    end

    protected

    def conn
      if @conn.nil?
        if @config[:socket]
          target = @config[:socket]
        else
          target = "#{@config[:host]}:#{@config[:port]}"
        end
        @conn = Palmade::Tapsilog::Conn.new(target, @config[:key])
        @conn.max_tries = -1
      end
      @conn
    end

  end
end
