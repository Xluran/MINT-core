
module MINT

  class Button_sync_callback < CIO_sync_callback
    def sync_aio_to_activated
      true
    end

    def sync_aio_to_deactivated
      true
    end

  end

  class Button < CIO
    def initialize_statemachine
      if @statemachine.nil?
        parser = StatemachineParser.new(self)
        @statemachine = parser.build_from_scxml "#{File.dirname(__FILE__)}/button.scxml"

        @statemachine.reset

      end
    end

    def sync_event(event)
      process_event(event, Button_sync_callback.new)
    end

    def sync_aio_to_activated
      aio =  MINT2::AICommand.first(:name=>self.name)
      if (aio and not aio.is_in? :activated)
        aio.sync_event(:activate)
      end
      true
    end


    def sync_aio_to_deactivated
      aio =  MINT2::AICommand.first(:name=>self.name)
      if (aio and not aio.is_in? :deactivated)
        aio.sync_event(:deactivate)
      end
      true
    end
  end
end