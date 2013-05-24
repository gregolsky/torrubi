
require 'test/unit'
require 'torrubi/ui/console'
#require 'torrubi/events'

class ConsoleTests < Test::Unit::TestCase

  def setup
    @fake_publisher = FakePublisher.new
    @fake_messenger = FakeMessenger.new
    @console = Torrubi::UI::Console.new(@fake_publisher, @fake_messenger)
  end
  
  def test_publish_event_when_no_search_term_provided
    @fake_messenger.read_messages << ""
    @console.ask_for_search_term
    @fake_publisher.events.pop.is_a? Torrubi::Events::NoSearchTermProvided
  end
  
  def test_publish_event_when_search_requested
    @fake_messenger.read_messages << "test"
    @console.ask_for_search_term
    @fake_publisher.events.pop.is_a? Torrubi::Events::SearchRequested
  end
  
  def test_publish_torrent_selected_when_valid_torrent_selected
    @fake_messenger.read_messages << "2"
    @console.select_result(
      [ Mock.new({ :magnet_link => lambda { || 1 } }) ] * 3, 
      'test', 
      1)
    e = @fake_publisher.events.pop
    e.is_a? Torrubi::Events::TorrentSearchResultSelected
    assert !(e.magnet_link.nil?)
  end
  
  def test_publish_torrent_selected_when_next_page_is_selected
    @fake_messenger.read_messages << "\n"
    @console.select_result(
      [ Mock.new({ :magnet_link => lambda { || 1 } }) ] * 30, 
      'test', 
      1)
    e = @fake_publisher.events.pop
    e.is_a? Torrubi::Events::SearchRequested
    assert e.page == 2
  end
  
  class FakePublisher
    
    attr_reader :events
    
    def initialize
      @events = []
    end
    
    def publish(event)
      @events << event
    end
    
  end

  class FakeMessenger
  
    attr_reader :read_messages
  
    def initialize
      @read_messages = []
    end
    
    def write(text)
    
    end
    
    def read
      @read_messages.pop
    end
  
  end
  
  class Mock
    
    def initialize(properties)
      @properties = properties
    end
    
    def method_missing(name, *args, &block)
        if args.nil? or args.length == 0
          @properties[name.intern].call
        else
          @properties[name.intern].call(args)
        end
      rescue NoMethodError => nme
        raise "#{name} not registered in mock"
      
    end
    
  end

end
