require 'cgi'

module Palmade::Tapsilog
  class Utils

    def self.symbolize_keys(hash)
      hash.inject({}){|result, (key, value)|
        new_key = key.kind_of?(String) ? key.to_sym : key
        new_value = value.kind_of?(Hash) ? symbolize_keys(value) : value
        result[new_key] = new_value
        result
      }
    end

    def self.is_port_open?(ip, port)
      begin
        ::Timeout::timeout(1) do
          begin
            s = TCPSocket.new(ip, port)
            s.close
            return true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            return false
          end
        end
      rescue ::Timeout::Error
      end

      return false
    end

    def self.process_running?(pid)
      Process.getpgid(pid) != -1
    rescue Errno::ESRCH
      false
    end

    def self.pidf_running?(pid_file)
      if pid = pidf_read(pid_file)
        process_running?(pid) ? pid : false
      else
        nil
      end
    end

    def self.pidf_read(pid_file)
      if File.exists?(pid_file) && File.file?(pid_file) && pid = File.read(pid_file)
        pid.to_i
      else
        nil
      end
    end

    def self.pidf_kill(pid_file, timeout = 30)
      if timeout == 0
        pidf_send_signal('INT', pid_file, timeout)
      else
        pidf_send_signal('QUIT', pid_file, timeout)
      end
    end

    def self.pidf_send_signal(signal, pid_file, timeout = 30)
      if pid = pidf_read(pid_file)
        Process.kill(signal, pid)
        ::Timeout.timeout(timeout) do
          sleep 0.1 while process_running?(pid)
        end
        pid
      else
        nil
      end
    rescue ::Timeout::Error
      pidf_force_kill pid_file
    rescue Interrupt
      pidf_force_kill pid_file
    rescue Errno::ESRCH # No such process
      pidf_force_kill pid_file
    end

    def self.pidf_force_kill(pid_file)
      if pid = pidf_read(pid_file)
        Process.kill("KILL", pid)
        File.delete(pid_file) if File.exist?(pid_file)
        pid
      else
        nil
      end
    end

    def self.pidf_clean(pid_file)
      unless pidf_running?(pid_file)
        File.delete(pid_file) if File.exists?(pid_file)
      end
    end

    # Taken from github accumulator/uri

    def self.query_string_to_hash(query_string, options={})
      return nil if query_string == nil or query_string.empty?
      defaults = {:notation => :subscript}
      options = defaults.merge(options)
      if ![:flat, :dot, :subscript].include?(options[:notation])
        raise ArgumentError,
          "Invalid notation. Must be one of: [:flat, :dot, :subscript]."
      end
      dehash = lambda do |hash|
        hash.each do |(key, value)|
          if value.kind_of?(Hash)
            hash[key] = dehash.call(value)
          end
        end
        if hash != {} && hash.keys.all? { |key| key =~ /^\d+$/ }
          hash.sort.inject([]) do |accu, (key, value)|
            accu << value; accu
          end
        else
          hash
        end
      end
      return ((query_string.split("&").map do |pair|
        pair.split("=", -1) if pair && pair != ""
      end).compact.inject({}) do |accumulator, (key, value)|
        value = true if value.nil?
        key = CGI::unescape(key)
        if value != true
          value = CGI::unescape(value).gsub(/\+/, " ")
        end
        if options[:notation] == :flat
          if accumulator[key]
            raise ArgumentError, "Key was repeated: #{key.inspect}"
          end
          accumulator[key] = value
        else
          if options[:notation] == :dot
            array_value = false
            subkeys = key.split(".")
          elsif options[:notation] == :subscript
            array_value = !!(key =~ /\[\]$/)
            subkeys = key.split(/[\[\]]+/)
          end
          current_hash = accumulator
          for i in 0...(subkeys.size - 1)
            subkey = subkeys[i]
            current_hash[subkey] = {} unless current_hash[subkey]
            current_hash = current_hash[subkey]
          end
          if array_value
            current_hash[subkeys.last] = [] unless current_hash[subkeys.last]
            current_hash[subkeys.last] << value
          else
            current_hash[subkeys.last] = value
          end
        end
        accumulator
      end).inject({}) do |accumulator, (key, value)|
        accumulator[key] = value.kind_of?(Hash) ? dehash.call(value) : value
        accumulator
      end
    end

    def self.hash_to_query_string(hash)
      # Check for frozenness
      if hash == nil or hash.empty?
        return nil
      end
      if !hash.respond_to?(:to_hash)
        raise TypeError, "Can't convert #{hash.class} into Hash."
      end
      hash = hash.to_hash
      hash = hash.map do |key, value|
        key = key.to_s if key.kind_of?(Symbol)
        [key, value]
      end
      hash.sort! # Useful default for OAuth and caching

      # Algorithm shamelessly stolen from Julien Genestoux, slightly modified
      buffer = ""
      stack = []
      e = lambda do |component|
        CGI::escape(component.to_s)
      end
      hash.each do |key, value|
        if value.kind_of?(Hash)
          stack << [key, value]
        elsif value.kind_of?(Array)
          stack << [
            key,
            value.inject({}) { |accu, x| accu[accu.size.to_s] = x; accu }
          ]
        elsif value == true
          buffer << "#{e.call(key)}&"
        else
          buffer << "#{e.call(key)}=#{e.call(value)}&"
        end
      end
      stack.each do |(parent, hash)|
        (hash.sort_by { |key| key.to_s }).each do |(key, value)|
          if value.kind_of?(Hash)
            stack << ["#{parent}[#{key}]", value]
          elsif value == true
            buffer << "#{parent}[#{e.call(key)}]&"
          else
            buffer << "#{parent}[#{e.call(key)}]=#{e.call(value)}&"
          end
        end
      end
      buffer.chop
    end

  end
end
