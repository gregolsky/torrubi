
require_relative 'piratebay'
require_relative 'transmission'

module Torrubi

  class Console

    def initialize(host = "127.0.0.1", port = 9091)
      @searchClient = PirateBay::Client.new
      @torrentClient = TransmissionRpc::Client.new(host, port)
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
      @results = @searchClient.search(term)
    end
    
    def perform_operation_on_selected
      if @selected > 0 and @selected < @results.length
        magnet = @results[@selected - 1].magnetLink
        begin
          @torrentClient.add(magnet)
          puts "Torrent added"
          puts magnet
        rescue Exception => e  
          puts e.message 
        end
      else
        puts "Invalid torrent number"
        exit 0
      end
    end

  end
  
  class TvShowsConsole < Console
    
    protected
    
    def get_search_term
      printf "Search title: "
      title =  STDIN.gets.chomp
      printf "Season nr: "
      snr = STDIN.gets.chomp      
      printf "Episode nr: "
      epnr = STDIN.gets.chomp
      epnr = "0#{epnr}" unless epnr.length != 1
      snr = "0#{epnr}" unless snr.length != 1
      "#{title} S#{snr}E#{epnr}"
    end
    
  end

  class RtorrentConsole < Console
  
    def perform_operation_on_selected
      if @selected > 0 and @selected < @results.length
        magnet = @results[@selected - 1].magnetLink
        begin
          system 'rtorrent #{magnet}'
        rescue Exception => e  
          puts e.message 
        end
      else
        puts "Invalid torrent number"
        exit 0
      end
    end
  end
end
