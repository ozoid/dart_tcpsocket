# dart_tcpsocket
Dart Persistent TCP Socket Client Example 

All examples I found previously online, disconnected after sending, so I made my own version that seems to work ok.

This example has a persistent connection and listener that allows the TCP channel to stay open so you can send and receive multiple strings of data.


androidSock.dart - main tcp socket control

messageHandler.dart - a solution to sync tx/rx and pass incoming data to commandHandler.dart

commandHandler.dart - handle incoming messages and run associated functions.

messageBuilder.dart - a utility to build messages to send for a simple protocol.

In main:

    import 'androidSock.dart';
    import 'messageHandler.dart';
    
    Comms bbComms; 

    class MyApp extends StatelessWidget {
     // This widget is the root of your application.
      MyApp(){
        bbComms = AndroidSock();
      }
    ...
     void sendStart(){
        bbComms.messaging.sendMessage(MessageType.START_GAME, callback: widget.callback);
     }
    ... 

