require 'torrubi/events'
require 'torrubi/search/piratebay'
require 'torrubi/config'

module Torrubi
  module UI
    class Console
    
      @@instance = Console.new

      def initialize(eventPublisher)
        @searchClient = searchClient
        @eventPublisher = eventPublisher
        @results = nil
        @selected = nil
        @pageNr = 0
        @term = term
      end

      def run
        if @term.nil?
          get_search_term
        end

        while @selected.to_i == 0

          self.perform_search
          self.print_search_results
          self.select_result

          @pageNr += 1

        end
        
        @eventPublisher.publish(Events::TorrentSearchResultSelected.new(self.get_selected_result))
        
      rescue Interrupt
        puts "Good bye!"
        exit 1    
      end

      def ask_for_search_term
        printf "Search: "
        term = STDIN.gets.chomp
        @eventPublisher.publish(Events::NoSearchTermProvided.new) unless not term.nil?
        @eventPublisher.publish(Events::SearchRequested.new(term))
      end

      def print_search_results(results)
        if results.length > 0
          nr = @pageNr * (results.length) + 1
          results.each_with_index do |t, i|
            
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
      
      def get_selected_result
        sel = @selected.to_i - 1
        if sel.between?(0, @results.length)
          magnet = @results[sel].magnetLink
          puts "Torrent added"
          magnet
        else
          puts "Invalid torrent number"
        end
      end

    end
  end
end
