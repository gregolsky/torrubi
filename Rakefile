
task :default => [:test]

task :test do
    ruby "test/*.rb"
end

task :profile do
  require 'profile'
  ruby "-Ilib bin/torrubi-transmission"
end
