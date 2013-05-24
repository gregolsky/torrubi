require 'torrubi/events'
require 'torrubi/infrastructure'
require 'torrubi/search/piratebay'
require 'torrubi/config'

module Torrubi
  module UI
   
    class Console
    
      def initialize(event_publisher = nil, messenger = nil)
        @eventPublisher = Infrastructure::SyncEventPublisher.instance
        @messenger = ConsoleMessenger.new
      end

      def ask_for_search_term
        @messenger.write "Search: "
        term = @messenger.read
        @eventPublisher.publish(Events::NoSearchTermProvided.new) unless not term.nil?
        @eventPublisher.publish(Events::SearchRequested.new(term))
      end

      def print_search_results(results, term, page)
        if results.length > 0
          nr = page * (results.length) + 1
          results.each_with_index do |t, i|
            
            @messenger.write "#{nr + i}.\t#{t.name}\n\tS: #{t.seedCount}\tL: #{t.leechCount}\tSize: #{t.size}\tBy: #{t.uploadedBy}\n"
          end
        else
          @messenger.write 'No results found\n'
          exit 0
        end
      end

      def select_result(results, term, page)
        @messenger.write "Add to queue (number or ENTER for next page): "
        selected = @messenger.read.downcase.to_i - 1
        if selected.between?(0, results.length)
          magnet = results[selected].magnetLink
          @messenger.write "Torrent added\n"
          @eventPublisher.publish(Events::TorrentSearchResultSelected.new(magnet))
        elsif selected == -1
          if results.length < 30
            @messenger.write "No more results\n"
          else
            @eventPublisher.publish(Events::SearchRequested.new(term, page + 1))
          end
        else
          @messenger.write "Invalid torrent number\n"
        end
      end
      
      def perform_search
        @results = @searchClient.search(@term, @pageNr)
      rescue SearchError => se
        @eventPublisher.publish(Events::SearchError.new(se))
      end
      
      def report_search_error(error_message = nil)
        @messenger.write 'Search error. Try again later.\n'
        @messenger.write '#{error_message}\n'
        exit 0
      end
      
    end
    
    class ConsoleMessenger
    
      def write(text)
        puts text
      end
      
      def read
        STDIN.gets.chomp
      end
      
    end
    
  end
end
