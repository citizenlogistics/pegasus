require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "pegasus"
    gem.summary = %Q{pegasus: unicorn-steady, redis-backed, shared-nothing worker processes}
    gem.description = %Q{pegasus: unicorn-steady, redis-backed, shared-nothing worker processes}
    gem.email = "joe@citizenlogistics.com"
    gem.homepage = "http://github.com/citizenlogistics/pegasus"
    gem.authors = ["Joe Edelman"]
    gem.add_dependency 'configurer'
    gem.add_dependency 'unicorn_horn'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "pegasus #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
