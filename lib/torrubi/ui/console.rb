require 'torrubi/events'
require 'torrubi/infrastructure'
require 'torrubi/search/piratebay'
require 'torrubi/config'

module Torrubi
  module UI
   
    class Console
    
      def initialize(event_publisher = nil, messenger = nil)
        @event_publisher = event_publisher.nil? ? Infrastructure::SyncEventPublisher.instance : event_publisher
        @messenger = messenger.nil? ? ConsoleMessenger.new : messenger
      end

      def ask_for_search_term
        @messenger.write "Search: "
        term = @messenger.read
        @event_publisher.publish(Events::NoSearchTermProvided.new) unless not term.nil?
        @event_publisher.publish(Events::SearchRequested.new(term))
      end

      def print_search_results(results, term, page)
        if results.length > 0
          nr = page * (results.length) + 1
          results.each_with_index do |t, i|
            
            @messenger.write "#{nr + i}.\t#{t.name}\n\tS: #{t.seed_count}\tL: #{t.leech_count}\tSize: #{t.size}\tBy: #{t.uploaded_by}\n"
          end
        else
          @messenger.write "No results found\n"
          exit 0
        end
      end

      def select_result(results, term, page)
        @messenger.write "Add to queue (number or ENTER for next page): "
        selected = @messenger.read.downcase.to_i - 1
        if selected.between?(0, results.length)
          magnet = results[selected].magnet_link
          @messenger.write "Torrent added\n"
          @event_publisher.publish(Events::TorrentSearchResultSelected.new(magnet))
        elsif selected == -1
          if results.length < 30
            @messenger.write "No more results\n"
          else
            @event_publisher.publish(Events::SearchRequested.new(term, page + 1))
          end
        else
          @messenger.write "Invalid torrent number\n"
        end
      end
      
      def report_search_error(error_message = nil)
        @messenger.write "Search error. Try again later.\n"
        @messenger.write "#{error_message}\n"
        exit 0
      end
      
    end
    
    class ConsoleMessenger
    
      def write(text)
        print text
      end
      
      def read
        STDIN.gets.chomp
      end
      
    end
    
  end
end
