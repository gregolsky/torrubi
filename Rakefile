
task :default => [:test]

task :test do
  require 'rake/testtask'
  Rake::TestTask.new do |t|
    t.libs = ["lib"]
    t.warning = true
    t.verbose = true
    t.test_files = FileList['test/test_*.rb']
  end
end

task :run do
    ruby "-Ilib bin/torrubi"
end

task :profile do
  require 'profile'
  ruby "-Ilib bin/torrubi"
end
