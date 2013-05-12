require 'transmission-rpc'

module TorrentClient
  class TransmissionDaemon
    
    def initialize(config)
      Transmission::configure do |cfg|
        cfg.ip = config.host
        cfg.port = config.port  
      end
    end
    
    def add(magnet)
      Transmission::RPC::Torrent + magnet
    end
    
  end
end
