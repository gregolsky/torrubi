require 'torrubi/events'
require 'torrubi/infrastructure'
require 'torrubi/search/piratebay'
require 'torrubi/config'

module Torrubi
  module UI
    class Console
    
      def initialize()
        @eventPublisher = Infrastructure::SyncEventPublisher.instance
      end

      def ask_for_search_term
        printf "Search: "
        term = STDIN.gets.chomp
        @eventPublisher.publish(Events::NoSearchTermProvided.new) unless not term.nil?
        @eventPublisher.publish(Events::SearchRequested.new(term))
      end

      def print_search_results(results, term, page)
        if results.length > 0
          nr = page * (results.length) + 1
          results.each_with_index do |t, i|
            
            puts "#{nr + i}.\t#{t.name}\n\tS: #{t.seedCount}\tL: #{t.leechCount}\tSize: #{t.size}\tBy: #{t.uploadedBy}"
          end
        else
          puts 'No results found'
          exit 0
        end
      end

      def select_result(results, term, page)
        printf "Add to queue (number or ENTER for next page): "
        selected = STDIN.gets.chomp.downcase.to_i - 1
        puts "#{selected} asdasdas"
        if selected.between?(0, results.length)
          magnet = results[selected].magnetLink
          puts "Torrent added"
          @eventPublisher.publish(Events::TorrentSearchResultSelected.new(magnet))
        elsif selected == -1
          if results.length < 30
            puts "No more results"
          else
            @eventPublisher.publish(Events::SearchRequested.new(term, page + 1))
          end
        else
          puts "Invalid torrent number"
        end
      end
      
      def perform_search
        @results = @searchClient.search(@term, @pageNr)
      rescue
        puts 'Search error. Try again later.'
        exit 0
      end
      
      def report_search_error(error_message = nil)
        puts 'Search error. Try again later.'
        puts error_message
      end
      
    end
  end
end
