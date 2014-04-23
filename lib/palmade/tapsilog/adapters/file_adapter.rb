module Palmade::Tapsilog::Adapters
  class FileAdapter < BaseAdapter

    def write(log_message)
      service = log_message[1].to_s
      log_message[5] = Palmade::Tapsilog::Utils.hash_to_query_string(log_message[5])

      file = get_file_descriptor(service)
      if file
        log_message.pop if log_message[5].nil? or log_message[5].empty?
        file.puts(log_message.join("|"))
      else
        STDERR.puts "Unknown service: #{service}"
      end
    end

    def flush
      @services.each do |name, service|
        fd = service[:file]
        unless fd.nil?
          fd.fsync if fd.fileno > 2
        end
      end
    end

    def close
      @services.each do |name, service|
        fd = service[:file]
        unless fd.nil?
          fd.close unless fd.closed?
        end
      end
    end

    protected

    def get_file_descriptor(service_name)
      service_name = resolve_service_name(service_name)
      service = @services[service_name]

      return nil if service.nil?

      if service[:file].nil?
        service[:file] = open_file_descriptor(service)
      end
      service[:file]
    end

    def resolve_service_name(service_name)
      if @services[service_name].nil?
        if @config[:autocreate]
          @services[service_name] = {
            :target => File.join(@config[:autocreate], service_name)
          }
        else
          return 'default'
        end
      end
      service_name
    end

    def open_file_descriptor(service)
      logfile = service[:target]

      if logfile =~ /^STDOUT$/i
        $stdout
      elsif logfile =~ /^STDERR$/i
        $stderr
      else
        File.open(logfile, 'ab+')
      end
    end

  end
end
