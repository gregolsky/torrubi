
require_relative 'piratebay'
require_relative 'torrent-client'

module Torrubi

  class Console

    def initialize(searchClient, torrentClient)
      @searchClient = searchClient
      @torrentClient = torrentClient
      @results = nil
      @selected = nil
    end

    def run
      self.perform_search(get_search_term)
      self.print_search_results
      self.select_result
      self.perform_operation_on_selected
    end

  protected
  
    def get_search_term
      printf "Search: "
      STDIN.gets.chomp
    end

    def print_search_results
      if @results.length > 0
        @results[0..9].each_with_index do |t, i|
          puts "#{i + 1}.\t#{t.name}\n\tS: #{t.seedCount}\tL: #{t.leechCount}\tSize: #{t.size}\tBy: #{t.uploadedBy}"
        end
      else
        puts 'No results found'
        exit 0
      end
    end

    def select_result
      printf "Add to queue (enter number): "
      @selected = STDIN.gets.chomp.to_i
    end
    
    def perform_search(term)
      begin
        @results = @searchClient.search(term)
      rescue
        puts 'Search error. Try again later.'
        exit 0
      end
    end
    
    def perform_operation_on_selected
      if @selected > 0 and @selected < @results.length
        magnet = @results[@selected - 1].magnetLink
        begin
          @torrentClient.add(magnet)
          puts "Torrent added"
        rescue Exception => e  
          puts e.message 
        end
      else
        puts "Invalid torrent number"
        exit 0
      end
    end

  end
  
  class TransmissionDaemonConsole < Console

    def initialize
      @cfg = TransmissionDaemonConfig.new
      super(PirateBay::Client.new, TorrentClient::TransmissionDaemon.new(@cfg.host, @cfg.port))
    end
    
  end

  class RtorrentConsole < Console
  
    def initialize
      @cfg = RtorrentConfig.new
      super(PirateBay::Client.new, TorrentClient::Rtorrent.new(@cfg.watch_directory))    
    end
    
  end
end
