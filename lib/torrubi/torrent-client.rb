
require 'transmission-rpc'

module TorrentClient
  class TransmissionDaemon
    
    def initialize(host, port)
      Transmission::configure do |cfg|
        cfg.ip = host
        cfg.port = port  
      end
    end
    
    def add(magnet)
      Transmission::RPC::Torrent + magnet
    end
    
  end
  
  class Rtorrent
  
    @@magnetRegex = /xt=urn:btih:([^&\/]+)/
  
    def initialize(watch_directory)
      @watch_directory = watch_directory
    end
    
    def file_name_from_magnet(magnet)
      m = @@magnetRegex.match(magnet)
      "meta-#{m[1]}.torrent"
    end
    
    def file_content_from_magnet(magnet)
      "d10:magnet-uri#{magnet.length}:#{magnet}e"
    end
    
    def add(magnet)
      fpath = File.join(File.expand_path(@watch_directory), self.file_name_from_magnet(magnet))
      File.open(fpath, 'w') { |f| f.write(self.file_content_from_magnet(magnet)) }
    end
  
  end
  
end
