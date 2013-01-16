 $:.push File.expand_path("../lib", __FILE__)
 require "torrubi/version"

 Gem::Specification.new do |s|
   s.name        = "torrubi"
   s.version     = Torrubi::VERSION
   s.authors     = ["Grzegorz Lachowski"]
   s.email       = ["gregory.lachowski@gmail.com"]
   s.homepage    = "https://github.com/gregorl/torrubi"
   s.summary     = %q{Simple torrent management utility}
   s.description = %q{Simple torrent management utility}

   s.rubyforge_project = "torrubi"

   s.files         = `git ls-files`.split("\n")
   s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
   s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
   s.require_paths = ["lib"]

   s.add_dependency('hpricot')
   s.add_dependency('transmission-rpc')
 end
