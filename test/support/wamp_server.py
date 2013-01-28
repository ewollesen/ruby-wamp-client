import sys

from twisted.internet import reactor
from twisted.python import log
from autobahn.wamp import WampServerFactory, \
                          WampServerProtocol, \
                          exportRpc
from autobahn.websocket import listenWS

class RpcServerProtocol(WampServerProtocol):

   @exportRpc
   def add(self, x, y):
      return x + y

   def onSessionOpen(self):
      self.registerForPubSub("/mpd/test")

if __name__ == '__main__':
   factory = WampServerFactory("ws://localhost:9001", debug=True)
   factory.protocol = RpcServerProtocol
   log.startLogging(sys.stdout)
   listenWS(factory)
   print "Here we go"
   sys.stdout.flush() # flush the line so that tests know we're up
   sys.stderr.flush()
   reactor.run()
