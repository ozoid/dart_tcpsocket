import 'dart:core';
import 'dart:developer';
import 'messageHandler.dart';

class CommandHandler{
//-------------------------------------  
  void doCommand(Message message){
    switch (message.messageType){
      case MessageType.GAME_START:
        startGame(message);
        break;
      case MessageType.LOGIN:
        loginUser(message);
        break;
      case MessageType.UNKNOWN:
        //do something
        break;
      case MessageType.VOID_GAME:
        //do something else
        break;
      default:
        break;
    }
     if(message.callback != null) {
      message.callback();
    }
  }
//-------------------------------------  
  void startGame(Message msg){
    log("Game Started ${msg.debugText}");    
  }
//-------------------------------------  
  void loginUser(Message msg){
    if(msg.text == "Success"){
      log("User Logged in");
      return;
    }
    log("User Failed to login");
  }
//-------------------------------------  
}
