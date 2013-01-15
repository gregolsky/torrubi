
require 'open-uri'
require 'nokogiri'

module PirateBay

  class Client

    @@url = 'http://thepiratebay.se'

    def search(term)
      encodedTerm = URI::encode(term)
      searchUrl = "#{@@url}/search/#{encodedTerm}/0/7/0"
      webPage = WebPage.new(searchUrl)
      torrents = webPage.css('table#searchResult tr')
        .map { |r| Torrent.from_table_row(r) unless r.css('a.detLink').length == 0 }
        .select { |t| t != nil } 
    end
  end

  class Torrent

    attr_reader :name, :magnetLink, :desc, :seedCount, :leechCount

    def initialize(name, magnetLink, desc, seedCount, leechCount)
      @name = name
      @magnetLink = magnetLink
      @desc = desc
      @seedCount = seedCount
      @leechCount = leechCount
    end

    def Torrent.from_table_row(row)
      name = row.css('a.detLink').text.chomp
      magnetLink = row.css('a[title="Download this torrent using magnet"]')[0]['href'].chomp
      desc = row.css('.detDesc').text.chomp
      seedCount = row.css('td')[2].text.chomp.to_i
      leechCount = row.css('td')[3].text.chomp.to_i

      Torrent.new(name, magnetLink, desc, seedCount, leechCount)
    end  
  end

  class WebPageNode
    def initialize(nokoNode)
      @node = nokoNode
    end

    def css(selector)
      @node.css(selector)
    end
  end

  class WebPage < WebPageNode
    def initialize(url)
      super(Nokogiri::HTML(open(url)))
      @url = url
    end
  end

end
