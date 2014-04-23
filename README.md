# Tapsilog, an asynchronous logging service

  Tapsilog is a super customized fork of Analogger. Tapsilog allows you to attach tags to log messages so that it can be searched easily.
  Currently, Tapsilog supports files and mongodb as storage backend.

**Supported adapters**
  
  - file - Logs to files, STDOUT or STDERR
  - mongo - Logs to mongoDB
  - proxy - Forwards logs to another tapsilog server

**Gems required for mongoDB support**

  - mongo
  - bson
  - bson_ext

**Compatibility with analogger**

  Tapsilog is mostly compatible with analogger client. Though there is a known quirk.
  When using the analogger client, text after a colon will be interpreted as a tag.
  Tapsilog URL encodes and decodes messages to circumvent this.
 
## Usage

**Tapsilog Server**
  
  See tapsilog --help for details 

**Sample File/Mongo Config**

    port: 19080
    host:
      - 127.0.0.1
    socket:
      - /tmp/tapsilog.sock
    daemonize: true
    key: the_real_logger

    syncinterval: 1

    backend:
      # Can be mongo or file
      adapter: mongo

      # Services not listed in logs section below will automatically be created under this collection (autocreate_namespace.service_name)
      # If autocreate is off and an unknown service is requested, tapsilog uses the service named 'default'.
      # If the service 'default' is not specified, tapsilog ignores the request 
      #
      # If file adapter is used, this is used to specify the directory where log files named by the service name are created.
      #autocreate: development

      # You can leave these blank and tapsilog connects using mongodb connection defaults
      #host: 127.0.0.1
      #port: 1234
      #user: root
      #password: somepassword
      #database: tapsilog
      
      # For mongo adapter, target refers to the mongodb collection
      # For file adapter, specify the path of the log file. You can also use stdout and stderr
    logs:
      - service: default
        target: default

      - service: access
        target: /some/special/logfile

        # You can override the global backend for this service
        backend:
          adapter: file

      - service: bizsupport
        target: bizsupport

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
    logger.level = Palmade::Tapsilog::Logger::DEBUG # defaults to INFO
    logger.info("I am logging a message.", {:my_name => "tapsilog", :my_number => 2})

