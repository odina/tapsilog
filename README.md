# Tapsilog, an asynchronous logging service

  Tapsilog is a super customized fork of Analogger. Tapsilog allows you to attach tags to log messages so that it can be searched easily.
  Currently, Tapsilog support files as storage backend.

**Supported adapters**
  
  - file - Logs to files, STDOUT or STDERR
  - proxy - Forwards logs to another tapsilog server

**Compatibility with analogger**

  Tapsilog is mostly compatible with analogger client. Though there is a known quirk.
  When using the analogger client, text after a colon will be interpreted as a tag.
  Tapsilog URL encodes and decodes messages to circumvent this.
 
## Usage

**Tapsilog Server**
  
  See tapsilog --help for details 


**Sample Proxy Config**

    socket:
      - /tmp/tapsilog_proxy.sock
    daemonize: true
    key: some_serious_key

    syncinterval: 1

    backend:
      adapter: proxy

      # You can connect to the destination tapsilog instance via tcpip or unix domain socket
      #host: 127.0.0.1
      #port: 19080
      #socket: /tmp/tapsilog.sock

      # Specify the authorization key of the tapsilog server to connect to
      key: the_real_logger

**Tapsilog Client**

  The tapsilog Logger class quacks like the ruby standard Logger.

**Sample**

    logger = Palmade::Tapsilog::Logger.new('default', '/tmp/tapsilog.sock', 'some_serious_key')
    logger.level = Palmade::Tapsilog::Logger::DEBUG
    logger.info("I am logging a message.")

