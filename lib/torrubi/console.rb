
require_relative 'piratebay'
require_relative 'config'
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
      pageNr = 0
      term = get_search_term
      begin
        while @selected.to_i == 0

          self.perform_search(term, pageNr)
          self.print_search_results
          self.select_result
          
          if @selected.include?(">")
            pageNr += 1
          end
          
        end
      rescue Interrupt
        puts "Good bye!"
        exit 0
      end
      
      self.perform_operation_on_selected
    end

  protected
  
    def get_search_term
      printf "Search: "
      STDIN.gets.chomp
    end

    def print_search_results
      if @results.length > 0
        @results.each_with_index do |t, i|
          puts "#{i + 1}.\t#{t.name}\n\tS: #{t.seedCount}\tL: #{t.leechCount}\tSize: #{t.size}\tBy: #{t.uploadedBy}"
        end
      else
        puts 'No results found'
        exit 0
      end
    end

    def select_result
      printf "Add to queue (enter number or '>' for next page): "
      @selected = STDIN.gets.chomp.downcase
    end
    
    def perform_search(term, page)
      begin
        @results = @searchClient.search(term, page)
      rescue
        puts 'Search error. Try again later.'
        exit 0
      end
    end
    
    def perform_operation_on_selected
      sel = @selected.to_i - 1
      if sel.between?(0, @results.length)
        magnet = @results[sel].magnetLink
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
