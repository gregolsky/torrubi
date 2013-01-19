require 'yaml'

module Torrubi
  class Config

    @@config_path = '~/.torrubi'

    def full_path
      File.expand_path(@@config_path)
    end

    def initialize
      @cfg = YAML.load_file(self.full_path)
    end
    
    private
    
    def get(subsection, key)
      if not @cfg
        self.create
      end
    
      begin
        @cfg['config'][subsection][key]
      rescue
        puts 'Configuration error'
        self.create
      end
    end
    
    def create
      cfg = [
        'config' => [
          'rtorrent' => [
            'watch_directory' => '~/download/watch'
          ]
          'transmission-daemon' => [
            'host' => '127.0.0.1',
            'port' => 9091    
          ]
        ]
      ]
      
      File.open(self.full_path, 'w') { |f| f.write(YAML.dump(cfg)) }
      puts 'Setup your ~/.torrubi file and run again'
      exit 0
    end
    
  end
  
  class TransmissionDaemonConfig < Config
  
    def host
      self.get('transmission-daemon', 'host')
    end
    
    def port
      self.get('transmission-daemon', 'port')
    end    
    
  end
  
  class RtorrentConfig < Config
    
    def watch_directory
      self.get('rtorrent', 'watch_directory')
    end
    
  end
  
end

      
