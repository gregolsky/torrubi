
require 'test/unit'
require_relative '../lib/torrubi/piratebay'

class PirateBayApiUnitTests < Test::Unit::TestCase

  def test_webpage_load
    page = PirateBay::WebPage.new('http://thepiratebay.se')
    assert page.search('table') != nil
  end
  
  def test_client
    cli = PirateBay::Client.new
    result = cli.search('ubuntu')
    assert result != nil
    assert result.length > 0
    item = result[0]
    assert item.size != nil and item.size.length > 0
    assert item.uploadedBy != nil and item.uploadedBy.length > 0
    assert (not item.name.include? "<")
  end

end
