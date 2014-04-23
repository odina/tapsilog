# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tapsilog}
  s.version = "0.3.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Palmade"]
  s.date = %q{2010-10-20}
  s.description = %q{Hydrid app-level logger from Palmade. Analogger fork.}
  s.email = %q{}
  s.executables = ["tapsilog", "tapsilog_tail"]
  s.extra_rdoc_files = ["lib/palmade/tapsilog.rb", "lib/palmade/tapsilog/adapters.rb", "lib/palmade/tapsilog/adapters/base_adapter.rb", "lib/palmade/tapsilog/adapters/file_adapter.rb", "lib/palmade/tapsilog/adapters/mongo_adapter.rb", "lib/palmade/tapsilog/adapters/proxy_adapter.rb", "lib/palmade/tapsilog/client.rb", "lib/palmade/tapsilog/conn.rb", "lib/palmade/tapsilog/logger.rb", "lib/palmade/tapsilog/protocol.rb", "lib/palmade/tapsilog/server.rb", "lib/palmade/tapsilog/utils.rb"]
  s.files = ["CHANGELOG", "INSTALL", "Manifest", "README.md", "Rakefile", "bin/tapsilog", "bin/tapsilog_tail", "lib/palmade/tapsilog.rb", "lib/palmade/tapsilog/adapters.rb", "lib/palmade/tapsilog/adapters/base_adapter.rb", "lib/palmade/tapsilog/adapters/file_adapter.rb", "lib/palmade/tapsilog/adapters/mongo_adapter.rb", "lib/palmade/tapsilog/adapters/proxy_adapter.rb", "lib/palmade/tapsilog/client.rb", "lib/palmade/tapsilog/conn.rb", "lib/palmade/tapsilog/logger.rb", "lib/palmade/tapsilog/protocol.rb", "lib/palmade/tapsilog/server.rb", "lib/palmade/tapsilog/utils.rb", "spec/config/tapsilog.yml", "spec/spec_helper.rb", "spec/tapsilog.rb", "tapsilog.gemspec", "test/test_helper.rb"]
  s.homepage = %q{}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Tapsilog", "--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{tapsilog}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Hydrid app-level logger from Palmade. Analogger fork.}
  s.test_files = ["test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<eventmachine>, [">= 0"])
    else
      s.add_dependency(%q<eventmachine>, [">= 0"])
    end
  else
    s.add_dependency(%q<eventmachine>, [">= 0"])
  end
end
