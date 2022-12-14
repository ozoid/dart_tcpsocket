import 'main.dart';
import 'messageBuilder.dart';
import 'commandHandler.dart';
import 'dart:core';
import 'dart:developer';
//#####################################################################
enum MessageType{
  GAME_START,
  VOID_GAME,
  LOGIN,
  UNKNOWN,
}
//#####################################################################
class Message {
  final String text;
  final String debugText;
  Function callback;
  bool init = false;
  MessageType messageType;
  DateTime timeSent = DateTime.now();
  Message(this.text,{this.debugText,this.callback,this.init}){
    messageType = getMessageType(text);
  }
  //-----------------------------------------------------------------
  MessageType getMessageType(String cmd){
    // example format @X.. e.g. @XE 123  or @XV
    String mType = cmd[2];
    switch (mType){
    //..
      case "V":
        return MessageType.VOID_GAME;
      case "L":
        return MessageType.LOGIN;
      case "S":
        return MessageType.GAMESTART;  
      default:
        return MessageType.UNKNOWN;    
    }
    return MessageType.UNKNOWN;
  }
}
//#####################################################################
class MessageHandler {
  bool removeSimilar = false;
  List<Message> messages = [];
  MessageBuilder builder = MessageBuilder();
  CommandHandler commandHandler = CommandHandler();
  MessageHandler(this.removeSimilar);
//-------------------------------------------------------------------
  /// From androidSock processData
  void doInboundCommands(String rawResult){
    List results = splitResults(rawResult);
    for(String result in results) {
      try {
      String cmdStart = result.substring(0,3);  // check the response starts with the same letters as the request.. (i.e. a reply)
        // match up sent message with received message and grab the additional data/callback
      List<Message> found = messages.where((iMsg) => iMsg.text.startsWith(cmdStart)).toList();
      if(found != null && found.length >0) {
        Message foundMsg = found.last;
        Message msg = Message(result,
          debugText: foundMsg.debugText,
          callback: foundMsg.callback,
          init: foundMsg.init
        );
        //----- Pass inbound message to commandHandler ----
        commandHandler.doCommand(msg);
        //-------------------------------------------------
        // remove messages from list
        if(removeSimilar){
          messages.removeWhere((iMsg) => iMsg.text.startsWith(cmdStart));
        }else {
          messages.remove(foundMsg);
        }
      }
      }catch(error){
        log("Command Error: $error $result");
      }
    }
  }
//-------------------------------------------------------------------
  List<Message> missedMessages(int ageSeconds){
    var mm = messages.where((iMsg) => iMsg.timeSent.isBefore(DateTime.now().subtract(Duration(seconds:ageSeconds)))).toList();
    if(mm!=null && mm.length >0) {
      return mm;
    }
    return [];
  }  
//-------------------------------------------------------------------  
  Future<String> sendMessage(MessageType messageType,{
    String options, Function callback, bool init}) async {
    Message message = builder.buildMessage(messageType,
      options: options, init: init
    );
    message.callback = callback;
    messages.add(message);
    return await bbComms.socketSendMessage(message);
  }
//----------------------------------------------------
  List<String> splitResults(String result){
    List<String> split = result.split("\r\n");
    List<String> results = [];
    if(split.length >0){
      for(int i=0;i<split.length;i++) {
        if(split[i].trim() != '') {
          results.add(split[i].trim());
        }
      }
    }
    return results;
  }
}
