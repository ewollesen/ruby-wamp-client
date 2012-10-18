require "wamp/client/version"
require "net/ws"
require "json"
require "timeout"


module WAMP
  class Client
    TYPEID_WELCOME = 0
    TYPEID_PREFIX = 1
    TYPEID_CALL = 2
    TYPEID_CALLRESULT = 3
    TYPEID_CALLERROR = 4
    TYPEID_SUBSCRIBE = 5
    TYPEID_UNSUBSCRIBE = 6
    TYPEID_PUBLISH = 7
    TYPEID_EVENT = 8


    def initialize(uri, options=nil)
      options ||= {:subprotocols => ["wamp"]}
      @session_id = nil
      @ws = Net::WS.new(uri, options)
      @subscriptions = {}
    end

    def open(request_uri="/")
      @ws.open(request_uri)
      receive_welcome_message
    end

    def close
      @ws.close
    end

    # FIXME: this doesn't seem to be working yet... I've no idea why
    def prefix(prefix, uri)
      payload = [TYPEID_PREFIX, prefix, uri]
      @ws.send_text(JSON.dump(payload))
    end

    def subscribe(uri_or_curie, cb)
      payload = [TYPEID_SUBSCRIBE, uri_or_curie]
      @ws.send_text(JSON.dump(payload))
      @subscriptions[uri_or_curie] = @subscriptions.fetch(uri_or_curie, []) << cb
    end

    def to_io
      @ws.to_io
    end

    def handle_message
      payload = receive_message

      case payload[0]
      when TYPEID_EVENT
        handle_event(payload)
      else
        $stderr.puts "Unhandled message type id: #{payload[0].pretty_inspect}"
      end
    end

    def check(timeout=5)
      Timeout.timeout(timeout) do
        loop {handle_message}
      end
    rescue Timeout::Error
      # noop
    end

    def publish(uri_or_curie, data)
      payload = [TYPEID_PUBLISH, uri_or_curie, data]
      @ws.send_text(JSON.dump(payload))
    end


    private

    def handle_event(payload)
      uri_or_curie = payload[1]
      data = payload[2]

      unless @subscriptions.fetch(uri_or_curie, nil)
        $stderr.puts "received event for unsubscribed channel: #{uri_or_curie.pretty_inspect}"
      end

      @subscriptions.fetch(uri_or_curie, []).each do |cb|
        cb.call(data, self, uri_or_curie)
      end
      data
    end

    def receive_welcome_message
      message = receive_message
      verify_welcome_message(message)
      @session_id = message[1]
    end

    def _receive(payload)
      JSON.parse(payload)
    end

    def receive_message
      _receive(@ws.receive_message)
    end

    def verify_welcome_message(message)
      raise "Invalid welcome message" unless TYPEID_WELCOME == message[0]
    end
  end
end
