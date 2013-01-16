
require 'rubygems'
require 'open-uri'
require 'hpricot'

module PirateBay

  class Client

    @@url = 'http://thepiratebay.se'

    def search(term)
      encodedTerm = URI::encode(term)
      searchUrl = "#{@@url}/search/#{encodedTerm}/0/7/0"
      webPage = WebPage.new(searchUrl)
      torrents = webPage.search('table#searchResult tr')
        .map { |r| Torrent.from_table_row(r) unless r.at('a.detLink') == nil }
        .select { |t| t != nil } 
    end
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
      
      desc, uploadedBy = row.at('font.detDesc').children.map { |ch|
        if ch.is_a?(Hpricot::Text)
          ch.to_s
        else
          ch.children.first.to_s
        end
      }
      
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
      @node.search(selector)
    end
  end

  class WebPage < WebPageNode
    def initialize(url)
      doc = Hpricot(open(url))
      super(doc)
      @url = url
    end
  end
  
  

end
