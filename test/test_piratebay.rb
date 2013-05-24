
require 'test/unit'
require 'torrubi/search/piratebay'

class PirateBayApiUnitTests < Test::Unit::TestCase

  def test_webpage_load
    page = PirateBay::WebPage.new('http://thepiratebay.se')
    assert page.search('table') != nil
  end
  
  def test_client_multiple_results
    cli = PirateBay::Client.new
    result = cli.search('ubuntu')
    assert result != nil
    assert result.length > 0

    item = result[0]
    assert item.size != nil and item.size.length > 0
    assert item.uploadedBy != nil and item.uploadedBy.length > 0
    assert !(item.name.include? "<")
  end
  
  def test_no_results
    cli = PirateBay::Client.new
    result = cli.search('asodifjsdfiojsodifjasdiofjasdof')
    assert !result.nil?
    assert result.length == 0
  end

end
