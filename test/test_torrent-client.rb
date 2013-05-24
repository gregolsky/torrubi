
require 'test/unit'
require 'torrubi/torrent/rtorrent'

class TorrentClientTests < Test::Unit::TestCase

  @@sampleMagnet = "magnet:?xt=urn:btih:0e1b4db611d71b0e3510bc1a47675a7d65ae5a8b&dn=Ubuntu+Server+12.10+64-bit+ISO&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&tr=udp%3A%2F%2Ftracker.publicbt.com%3A80&tr=udp%3A%2F%2Ftracker.istole.it%3A6969&tr=udp%3A%2F%2Ftracker.ccc.de%3A80"

  class Cfg
    attr_reader :watch_directory
    
    def initialize(watch_directory)
      @watch_directory = watch_directory
    end
  end

  def test_rtorrent_meta_file_from_magnet
    expected_content = 'd10:magnet-uri257:magnet:?xt=urn:btih:0e1b4db611d71b0e3510bc1a47675a7d65ae5a8b&dn=Ubuntu+Server+12.10+64-bit+ISO&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&tr=udp%3A%2F%2Ftracker.publicbt.com%3A80&tr=udp%3A%2F%2Ftracker.istole.it%3A6969&tr=udp%3A%2F%2Ftracker.ccc.de%3A80e'
    expected_file_name = 'meta-0e1b4db611d71b0e3510bc1a47675a7d65ae5a8b.torrent'
    
    c = TorrentClient::Rtorrent.new(Cfg.new('/tmp/test'))
    
    actualFilename = c.file_name_from_magnet(@@sampleMagnet)
    assert actualFilename == expected_file_name, "File name is wrong"
    
    actualContent = c.file_content_from_magnet(@@sampleMagnet)
    assert actualContent == expected_content, "Content is wrong"
    
  end

end
