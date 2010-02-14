require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "minx"
    gem.summary = %Q{Massive and pervasive concurrency}
    gem.description = %Q{An implementation of the CSP concurrency primitives}
    gem.email = "daniel.schierbeck@gmail.com"
    gem.homepage = "http://github.com/dasch/minx"
    gem.authors = ["Daniel Schierbeck"]
    gem.add_development_dependency "shoulda", ">= 0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

begin
  require 'yard'
  require 'yard/rake/yardoc_task'
  YARD::Rake::YardocTask.new do |t|
    extra_files = %w(LICENSE)
    t.files = ['lib/**/*.rb']
    t.options = ["--files=#{extra_files.join(',')}", "--no-private"]
  end
rescue LoadError
  task :yard do
    abort "YARD is not available. In order to run yard, you must: sudo gem install yard"
  end
end
