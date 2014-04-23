require 'rubygems'
gem 'echoe'
require 'echoe'

Echoe.new('tapsilog', '0.3.6') do |p|
  p.author         = "Palmade"
  p.project        = "tapsilog"
  p.summary        = "Hydrid app-level logger from Palmade. Analogger fork."

  p.dependencies   = ["eventmachine"]
  p.ignore_pattern = ["tmp/*"]

  p.need_tar_gz = false
  p.need_tgz = true

  p.clean_pattern += [ "pkg", "lib/*.bundle", "*.gem", ".config" ]
  p.rdoc_pattern = [ 'README', 'LICENSE', 'COPYING', 'lib/**/*.rb', 'doc/**/*.rdoc' ]
end

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/*.rb'].exclude('spec/spec_helper.rb')
  t.spec_opts.push("-f s")
end

task :default => [ :spec ]
