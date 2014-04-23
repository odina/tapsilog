module Palmade::Tapsilog
  module Adapters

    autoload :BaseAdapter, File.join(File.dirname(__FILE__), 'adapters/base_adapter')
    autoload :FileAdapter, File.join(File.dirname(__FILE__), 'adapters/file_adapter')
    autoload :ProxyAdapter, File.join(File.dirname(__FILE__), 'adapters/proxy_adapter')

  end
end
