
require 'test/unit'
require 'torrubi/ui/console'
require 'torrubi/events'

class ConsoleTests < Test::Unit::TestCase

  def setup
    @fake_publisher = FakePublisher.new
    @fake_messenger = FakeMessenger.new
    @console = Console.new(@fake_publisher, @fake_messenger)
  end
  
  def should_publish_event_when_no_search_term_provided
    @fake_messenger.read_messages << ""
    @console.ask_for_search_term
    @fake_publisher.events.pop.is_a? Events::NoSearchTermProvided
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
  
    def initialize(read_messages)
      @read_messages = read_messages
    end
    
    def write(text)
    
    end
    
    def read
      @read_messages.pop
    end
  
  end

end
