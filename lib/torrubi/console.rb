
require_relative 'piratebay'
require_relative 'config'

module Torrubi

  class Console

    def initialize(searchClient, torrentClient)
      @searchClient = searchClient
      @torrentClient = torrentClient
      @results = nil
      @selected = nil
      @pageNr = 0
      @term = nil
    end

    def run
      get_search_term

      while @selected.to_i == 0

        self.perform_search
        self.print_search_results
        self.select_result

        @pageNr += 1

      end
      
      self.perform_operation_on_selected
      
    rescue Interrupt
      puts "Good bye!"
      exit 0    
    end

  protected
  
    def get_search_term
      printf "Search: "
      @term = STDIN.gets.chomp
    end

    def print_search_results
      if @results.length > 0
        nr = @pageNr * (@results.length) + 1
        @results.each_with_index do |t, i|
          
          puts "#{nr + i}.\t#{t.name}\n\tS: #{t.seedCount}\tL: #{t.leechCount}\tSize: #{t.size}\tBy: #{t.uploadedBy}"
        end
      else
        puts 'No results found'
        exit 0
      end
    end

    def select_result
      printf "Add to queue (number or ENTER for next page): "
      @selected = STDIN.gets.chomp.downcase
    end
    
    def perform_search
      @results = @searchClient.search(@term, @pageNr)
    rescue
      puts 'Search error. Try again later.'
      exit 0
    end
    
    def perform_operation_on_selected
      sel = @selected.to_i - 1
      if sel.between?(0, @results.length)
        magnet = @results[sel].magnetLink
        @torrentClient.add(magnet)
        puts "Torrent added"
      else
        puts "Invalid torrent number"
        exit 0
      end
    end

  end
  
  class TransmissionDaemonConsole < Console

    def initialize
      require_relative 'torrent/transmission'
      @cfg = TransmissionDaemonConfig.new
      super(PirateBay::Client.new, TorrentClient::TransmissionDaemon.new(@cfg.host, @cfg.port))
    end
    
  end

  class RtorrentConsole < Console
  
    def initialize
      require_relative 'torrent/rtorrent'
      @cfg = RtorrentConfig.new
      super(PirateBay::Client.new, TorrentClient::Rtorrent.new(@cfg.watch_directory))    
    end
    
  end
end
