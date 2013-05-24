module Infrastructure

  class UI

    @@instance = nil
    
    def UI.set(ui)
      @@instance = ui
    end
    
    def UI.instance
      @@instance
    end
    
  end

  class SyncEventPublisher
    
    def initialize()
      @handlers = {}
      @message_bus = nil
    end
    
    def subscribe(event_type, handler)
      if not @handlers.has_key?(event_type)
        @handlers[event_type] = []
      end
      
      @handlers[event_type] << handler
    end
    
    def publish(event)
      @message_bus.enqueue(event)
    end
    
    def get_handlers(event)
      @handlers[event.class]
    end
    
    def connect_to(messageBus)
      @message_bus = messageBus
    end
    
    def SyncEventPublisher.instance
      @@instance
    end
    
    @@instance = SyncEventPublisher.new
    
    attr_reader :message_bus
    
  end
  
  class MessageBus
  
    def initialize
      @queue = []
    end
    
    def enqueue(msg)
      @queue << msg
    end

    def next_event
      @queue.pop
    end
  
  end
  
  class EventLoop
    def EventLoop.run
      
      event_publisher = SyncEventPublisher.instance
      bus = MessageBus.new
      event_publisher.connect_to(bus)
      
      yield
      
      while event = bus.next_event
        event_publisher.get_handlers(event).each { |handler| handler.new.handle(event) }
      end
    end
  end

end
