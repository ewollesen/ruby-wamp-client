# -*- coding: utf-8 -*-
require File.expand_path("../test_helper", File.dirname(__FILE__))
require "open3"
require File.expand_path("../../../rmpd/lib/rmpd", File.dirname(__FILE__))


describe WAMP::Client do

  def with_echo_server(&block)
    echo_server_path = File.expand_path("../support/echo_server.py",
                                        File.dirname(__FILE__))

    Open3.popen3(echo_server_path) do |stdin, stdout, stderr|
      stdout.readline # the readline tells us the server is up
      yield "localhost", 9001
    end
  end

  # it "should be sane" do
  #   true.must_equal true
  # end

  it "can send and receive message" do
    CHANNEL = "/mpd/test"

    host = "localhost"; port = 9001

    listener = WAMP::Client.new("ws://#{host}:#{port}",
                              :subprotocols => ["wamp"])
    listener.open
    listener.subscribe(CHANNEL, proc {|x| $stderr.puts "Rx: %p" % [x]})

    puts "listener subscribed"


    client = WAMP::Client.new("ws://#{host}:#{port}",
                              :subprotocols => ["wamp"])
    puts client.open
    client.publish(CHANNEL, "testing 1 2 3")

    puts "checking..."
    listener.check(0.1)

    client.publish(CHANNEL, "∆AIMON")

    puts "checking..."
    listener.check(0.1)

    client.publish(CHANNEL, {"file" => "∆AIMON"})

    puts "checking..."
    listener.check(0.1)

    config = StringIO.new <<EOF
development:
  hostname: admin@localhost
  port: 6601

test:
  hostname: admin@localhost
  port: 6601
EOF

    rmpd = Rmpd::Connection.new(config)
    pi = rmpd.search("artist", "aimon", "title", "current")
    client.publish(CHANNEL, pi)

    puts "checking..."
    listener.check(0.1)

    puts "closing"
    client.close
    listener.close

  end

end
