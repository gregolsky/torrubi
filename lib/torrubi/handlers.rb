require 'torrubi/console'
require 'torrubi/infrastructure'

module Torrubi

  module EventHandlers

    class TorrentSelectedRtorrentEventHandler
      def handle(event)
        require 'torrubi/torrent/rtorrent'
        cfg = Configuration::RtorrentConfig.new
        client = TorrentClient::Rtorrent.new(cfg)
        client.add(event.magnetLink)
      end
    end
    
    class TorrentSelectedTransmissionEventHandler
      def handle(event)
        require 'torrubi/torrent/transmission'
        cfg = Configuration::TransmissionDaemonConfig.new
        client = TorrentClient::TransmissionDaemon.new(cfg)
        client.add(event.magnetLink)
      end
    end
    
    class NoSearchTermProvidedEventHandler
      def handle(event)
        Infrastructure::UI.instance.ask_for_search_term
      end
    end
    
    class SearchRequestedEventHandler
      def handle(event)
        results = PirateBay::Client.new.search(event.term, event.page)
        Infrastructure::SyncEventPublisher.instance.publish(Events::SearchCompleted.new(results, event.page))
      rescue Exception => exc
        Infrastructure::SyncEventPublisher.instance.publish(Events::SearchError.new(exc))
      end
    end
    
    class SearchCompletedEventHandler
      def handle(event)
        Infrastructure::UI.instance.print_search_results(event.results, event.term, event.page)
        Infrastructure::UI.instance.select_result(event.results, event.term, event.page)
      end
    end
    
    class SearchErrorEventHandler
      def handle(event)
        Infrastructure::UI.instance.report_search_error(event.exception.message)
      end
    end

  end
  
end
