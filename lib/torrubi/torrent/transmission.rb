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
end
