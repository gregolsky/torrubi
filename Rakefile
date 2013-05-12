
task :default => [:test]

task :test do
    ruby "-Ilib test/*.rb"
end

task :run do
    ruby "-Ilib bin/torrubi"
end

task :profile do
  require 'profile'
  ruby "-Ilib bin/torrubi"
end
