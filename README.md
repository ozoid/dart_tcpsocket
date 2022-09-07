# dart_tcpsocket
Dart TCP Persistent Socket Example 

androidSock - main tcp socket control

messageHandler - a solution to sync tx/rx and pass incoming data to a commandHandler

In main:

    import 'androidSock.dart';
    Comms bbComms; 

    class MyApp extends StatelessWidget {
     // This widget is the root of your application.
      MyApp(){
        bbComms = AndroidSock();
      }
    ...

TX Data:
        
        bbComms.messaging.sendMessage(MessageType messageType, callback: callback);
        
RX Data:
In messageHandler doInboundCommands
pass inbound results to a commandHandler 

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
