
require 'open-uri'
require 'nokogiri'

module PirateBay

  class Client

    @@url = 'http://thepiratebay.se'

    def search(term, page = 0)
      encodedTerm = URI::encode(term)
      searchUrl = "#{@@url}/search/#{encodedTerm}/#{page}/7/0"
      webPage = WebPage.new(searchUrl)
      torrents = webPage.search('table#searchResult tr')
        .map { |r| Torrent.from_table_row(r) unless r.at('a.detLink') == nil }
        .select { |t| t != nil }
    rescue
      raise SearchError, "An error occurred while searching"
    end
  end
  
  class SearchError < Exception
  end

  class Torrent

    attr_reader :name, :magnetLink, :desc, :seedCount, :leechCount, :size, :uploadedBy

    def initialize(name, magnetLink, size, seedCount, leechCount, uploadedBy)
      @name = name
      @magnetLink = magnetLink
      @seedCount = seedCount
      @leechCount = leechCount
      @size = size
      @uploadedBy = uploadedBy
    end

    def Torrent.from_table_row(row)
      name = row.at('a.detLink').inner_html.chomp
      magnetLink = row.at('a[@title="Download this torrent using magnet"]')['href'].chomp
      
      desc, uploadedBy = row.at('font.detDesc').children.map do |ch|
        if WebPageNode.is_text?(ch)
          ch.to_s
        else
          ch.children.first.to_s
        end
      end
      
      parsedDesc = desc.scan(/Size ([0-9.]*.[A-Za-z]*),/)
      size = parsedDesc[0][0]
      
      seedCount = row.search('td')[2].inner_html.chomp.to_i
      leechCount = row.search('td')[3].inner_html.chomp.to_i

      Torrent.new(name, magnetLink, size, seedCount, leechCount, uploadedBy)
    end
    
  end

  class WebPageNode
    def initialize(node)
      @node = node
    end

    def search(selector)
      @node.css(selector)
    end
    
    def WebPageNode.is_text?(node)
      return node.is_a? Nokogiri::XML::Text
    end
  end

  class WebPage < WebPageNode
    def initialize(url)
      doc = Nokogiri::HTML(open(url))
      super(doc)
      @url = url
    end
  end
  
  

end
