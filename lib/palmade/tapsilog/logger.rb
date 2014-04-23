module Palmade::Tapsilog
  class Logger < Client
    LOG_LEVEL_TEXT = [ 'debug', 'info', 'warn', 'error', 'fatal', 'unknown' ]

    DEBUG, INFO, WARN, ERROR, FATAL, UNKNOWN = (0..5).to_a

    attr_accessor :level

    def initialize(*args, &block)
      super(*args, &block)
      @level = INFO
    end

    def info?
      @level <= INFO
    end

    def info(message = nil, tags = {}, &block)
      add(INFO, message, tags, &block)
    end

    def debug?
      @level <= DEBUG
    end

    def debug(message = nil, tags = {}, &block)
      add(DEBUG, message, tags, &block)
    end

    def error?
      @level <= ERROR
    end

    def error(message = nil, tags = {}, &block)
      add(ERROR, message, tags, &block)
    end

    def fatal?
      @level <= FATAL
    end

    def fatal(message = nil, tags = {}, &block)
      add(FATAL, message, tags, &block)
    end

    def warn?
      @level <= WARN
    end

    def warn(message = nil, tags = {}, &block)
      add(WARN, message, tags, &block)
    end

    def add(severity, message = nil, tags = {}, &block)
      case severity
      when 'authentication'
        return log_without_rails_extensions(severity, message)
      when String, Symbol
        severity = LOG_LEVEL_TEXT.index(severity.to_s.downcase) || UNKNOWN
      when nil
        severity = UNKNOWN
      end

      if severity < @level
        return true
      end

      log_level_text = LOG_LEVEL_TEXT[severity]
      message = yield if message.nil? && block_given?

      log_without_rails_extensions(log_level_text, message, tags)
    end

    alias_method :log_without_rails_extensions, :log
    alias_method :log, :add
  end
end

