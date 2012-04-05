module MINT2
  class Pointer < MINT::Element
    property :x, Integer, :default  => -1
    property :y, Integer, :default  => -1

    @publish_attributes = [:name,:states,:abstract_states,:new_states,:classtype, :mint_model, :x, :y]

    def self.published_attributes
      @publish_attributes = [:name,:states,:abstract_states,:new_states,:classtype, :mint_model, :x, :y]
    end

    def initialize_statemachine
      if @statemachine.nil?
        parser = StatemachineParser.new(self)
        @statemachine = parser.build_from_scxml "#{File.dirname(__FILE__)}/pointer.scxml"

        @statemachine.reset

      end
    end

    def consume(id)
      subscription = self.class.create_channel_name+"."+id.to_s+":*"
      RedisConnector.sub.psubscribe(subscription) # TODO all users
      RedisConnector.sub.on(:pmessage) { |key, channel, message|
        if (key.eql? subscription)
          x,y = JSON.parse message
          cache_coordinates x,y
          process_event("move") if not is_in? :moving
          restart_timeout
        end
      }
    end


    def cache_coordinates(x,y)
      @cached_x = x
      @cached_y = y
    end

    def start_timeout
      if not @timer
        @timer = EventMachine::Timer.new(0.1) do
          attribute_set(:x, @cached_x)
          attribute_set(:y, @cached_y)
          process_event("stop")
        end
      else
        puts "timer already started!!!"
      end
    end
    def stop_timeout
      if @timer
        # p "stopped timer"
        @timer.cancel
        @timer = nil
      end
    end
    def restart_timeout
      stop_timeout
      start_timeout
    end
  end

  class Pointer3D < Pointer
    property :z, Integer, :default  => -1
    attr_accessor :cached_x, :cached_y,:cached_z

    def cache_coordinates(x,y,z=nil)
      @cached_x = x if (x)
      @cached_y = y if (y)
      @cached_z = z if (z)
    end



    def start_timeout
      if not @timer
        @timer = EventMachine::Timer.new(0.1) do
          attribute_set(:x, @cached_x)
          attribute_set(:y, @cached_y)
          attribute_set(:z, @cached_z)

          process_event("stop")

        end
      else
        puts "timer already started!!!"
      end
    end

  end
end