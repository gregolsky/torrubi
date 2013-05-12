
require 'torrubi/config'
require 'torrubi/infrastructure'
require 'torrubi/console'
require 'torrubi/events'
require 'torrubi/handlers'

module Torrubi

  class Program

    def run
      Infrastructure::UI.set(UI::Console.new)
      options = Configuration::CommandLineOptions.create
      configure_event_handlers(options)
      Infrastructure::EventLoop.run do
        bootstrap(options)
      end
    rescue Interrupt
      exit 1  
    end
    
    private
    
      def configure_event_handlers(options)
        publisher = Infrastructure::SyncEventPublisher.instance
        
        torrentSelectedHandler = case options[:torrent_client].downcase
        when 'rtorrent'
          EventHandlers::TorrentSelectedRtorrentEventHandler
        when 'transmission'
          EventHandlers::TorrentSelectedTransmissionEventHandler
        else
          puts 'Invalid torrent client option'
          exit 1
        end
        
        publisher.subscribe(Events::TorrentSearchResultSelected, torrentSelectedHandler)
        publisher.subscribe(Events::NoSearchTermProvided, EventHandlers::NoSearchTermProvidedEventHandler)
        publisher.subscribe(Events::SearchRequested, EventHandlers::SearchRequestedEventHandler)
        publisher.subscribe(Events::SearchCompleted, EventHandlers::SearchCompletedEventHandler)
        publisher.subscribe(Events::SearchError, EventHandlers::SearchErrorEventHandler)

      end
      
      def bootstrap(options)
        publisher = Infrastructure::SyncEventPublisher.instance
        query = options[:query]
        if query.nil?
          publisher.publish(Events::NoSearchTermProvided.new)
        else
          publisher.publish(Events::SearchRequested.new(query))
        end 
      end
    
  end

end
