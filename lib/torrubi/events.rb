module Torrubi
  module Events

    class TorrentSearchResultSelected
      attr_reader :magnetLink
    
      def initialize(magnetLink)
        @magnetLink = magnetLink
      end
    end
    
    class NoSearchTermProvided  
    end
    
    class SearchRequested
      attr_reader :term, :page
      
      def initialize(term, page = 0)
        @term = term
        @page = page
      end
    end
    
    class SearchCompleted
      attr_reader :results, :page, :term
      
      def initialize(results, term, page = 0)
        @results = results
        @page = page
        @term = term
      end
    end
    
    class SearchError
      attr_reader :exception
    
      def initialize(exception)
        @exception = exception
      end
    end
    
  end
end
