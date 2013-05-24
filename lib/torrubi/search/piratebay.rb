
require 'open-uri'
require 'nokogiri'

module PirateBay

  class Client

    @@url = 'http://thepiratebay.se'

    def search(term, page = 0)
      encoded_term = URI::Parser.new.escape(term)
      search_url = "#{@@url}/search/#{encoded_term}/#{page}/7/0"
      web_page = WebPage.new(search_url)
      web_page.search('table#searchResult tr')
        .map { |r| Torrent.from_table_row(r) unless r.at('a.detLink') == nil }
        .select { |t| t != nil }
    rescue
      raise SearchError, "An error occurred while searching"
    end
  end
  
  class SearchError < Exception
  end

  class Torrent

    attr_reader :name, :magnet_link, :desc, :seed_count, :leech_count, :size, :uploaded_by

    def initialize(name, magnet_link, size, seed_count, leech_count, uploaded_by)
      @name = name
      @magnet_link = magnet_link
      @seed_count = seed_count
      @leech_count = leech_count
      @size = size
      @uploaded_by = uploaded_by
    end

    def Torrent.from_table_row(row)
      name = row.at('a.detLink').inner_html.chomp
      magnet_link = row.at('a[@title="Download this torrent using magnet"]')['href'].chomp
      
      desc, uploaded_by = row.at('font.detDesc').children.map do |ch|
        if WebPageNode.is_text?(ch)
          ch.to_s
        else
          ch.children.first.to_s
        end
      end
      
      parsedDesc = desc.scan(/Size ([0-9.]*.[A-Za-z]*),/)
      size = parsedDesc[0][0]
      
      seed_count = row.search('td')[2].inner_html.chomp.to_i
      leech_count = row.search('td')[3].inner_html.chomp.to_i

      Torrent.new(name, magnet_link, size, seed_count, leech_count, uploaded_by)
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
