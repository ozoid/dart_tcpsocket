# dart_tcpsocket
Dart Persistent TCP Socket Client Example 

All examples I found previously, disconnected after sending.

This example has a persistent connection and listener that allows the TCP channel to stay open so you can send and receive multiple strings of data.


androidSock.dart - main tcp socket control

messageHandler.dart - a solution to sync tx/rx and pass incoming data to a commandHandler


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
     void sendMessage(String text){
        Message msg = Message(text);
        bbComms.messaging.sendMessage(MessageType messageType, callback: widget.callback); //optional callback
     }
    ... 


RX Data:

In messageHandler doInboundCommands(..) - pass the inbound results to a commandHandler

e.g.

        class CommandHandler{
            void doCommand(Message message){
                switch (message.messageType){
                    case MessageType.UNKNOWN:
                        //do something
                        break;
                    case MessageType.VOID_GAME:
                        //do something else
                        break;
                    ...
