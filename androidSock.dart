import 'dart:typed_data';
import 'dart:core';
import 'dart:io';
import 'dart:async';
import 'dart:developer';
import 'messageHandler.dart';
//################################################################
abstract class Comms {
  FutureOr<String> socketSend(String text, String debugText);
  Future<String> socketSendMessage(Message message);
  MessageHandler messaging;
  void disconnect(String reason);
  void dispose();
}
//################################################################
class AndroidSock implements Comms{
  Socket socket;
  Timer timer;
  StreamSubscription<Uint8List> subscription;
  Function callback;
  bool init = false;
  bool connecting = false;
  MessageHandler messaging = MessageHandler(false);
  AndroidSock();
//-----------------------------------------------------------------
  Future<void> dataStream() async {
    subscription = socket.listen((data) async {
      processData(data);
    }, onError: (error) {
      dataError(error);
    }, onDone: () {
      disconnect("Server Closed Connection");
    }, cancelOnError: true);
  }
//-----------------------------------------------------------------
  Future<bool> connect() async {
    log("Connect");
    connecting = true;
    final Completer<bool> c = new Completer();
    await Socket.connect(ip, appPort, timeout: Duration(seconds:2))
        .then((Socket sock) async {
          socket = sock;
          socket.setOption(SocketOption.tcpNoDelay, true);
          connectionCount.value = 0;
          c.complete(true);
          connecting = false;
    }).catchError((error) {
      connectError(error);
      c.complete(false);
    });
    return c.future;
  }
//-----------------------------------------------------------------
   FutureOr<String> socketSend(String text, String debugText) async {
    if(!connection && !connecting) {
      bool connected = await connect();
      if(connected){
        await dataStream();
        connection = true;
        connectionCount.value++;
      }
    }
    if(connection) {
      bool sent = sendData(text,debugText);
      if(!sent){
        disconnect("Cannot Send - No Socket");
        await socketSend(text, debugText);
      }
      await Future.delayed(Duration(milliseconds:50));
      return "";
    }else{
      disconnect("Cannot Connect");
      return "";
    }
  }
//-----------------------------------------------------------------
  Future<String> socketSendMessage(Message message) async {
    return await socketSend(message.text, message.debugText);
  }
//-----------------------------------------------------------------
//@override
  void dispose(){
    timer?.cancel();
    timer = null;
    subscription?.cancel();
    subscription = null;
    socket?.close();
    socket?.destroy();
    socket = null;

}
//-----------------------------------------------------------------
  bool sendData(String text,String debugText) {
    if(text.trim() == ""){
      log("Empty Send");
      return false;
    }
    lastPoll.value = DateTime.now().toString();
    try {
      socket.write("$text\r\n");
    }catch(err){
      sendError(err.toString(), text, debugText);
      return false;
    }
    return true;
  }
//-----------------------------------------------------------------
  Future<bool> dataError(error) async{
    disconnect("Data Error:" + error.toString());
    return false;
  }
//----------------------------------------------------------------
  FutureOr<Uint8List> sendError(error,cmd,debugText) async{
    disconnect("Send Error: $cmd - $debugText :" + error.toString());
    return new Uint8List(0);
  }
//-----------------------------------------------------------------
  FutureOr<Null> connectErrorHandler(error,type,cmd,debugText) async{
    disconnect("Connect Error: $debugText :" + error.toString());
    return null;
  }
//-----------------------------------------------------------------
  FutureOr<Null> connectError(error) async{
    disconnect("Connect Error: " + error.toString());
    return null;
  }
//-----------------------------------------------------------------
  Future<void> reconnect() async{
    log("reconnect");
    connection = false;
    Timer.periodic(Duration(seconds:3), (Timer timer) async {
      try {
        log("@@ retry");
        await connect();
      } catch (e) {
        log("@@ error: $e");
      }
      if (socket != null) timer.cancel();
    });
  }
//-----------------------------------------------------------------
  void disconnect(String reason){
    log("${DateTime.now()} Disconnected: $reason");
    connectionCount.value--;
    connection = false;
    connecting = false;
    subscription?.cancel();
    socket?.close();
    socket?.destroy();
  }
//-----------------------------------------------------------------
  FutureOr<Null> onTimeout(){
    connection = false;
    log("${DateTime.now()} Socket Timeout: ");
  }
//-----------------------------------------------------------------
  Future<void> processData(Uint8List data) async{
    String result = new String.fromCharCodes(data).trim();
    if (connection == false)) {
      log("Reconnected");
      //..
    }
    connection = true;
    messaging.doInboundCommands(result);
  }
}
