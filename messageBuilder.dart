import 'messageHandler.dart';
//#####################################################################
class MessageBuilder{
  Message buildMessage(MessageType messageType,{String text, bool init}){
    switch(messageType){
      case MessageType.LOGIN:
        return Message("@XL $text", debugText:"Login");
      case MessageType.GAME_START:
        return Message("@XS", debugText:"Game Start");
      case MessageType.VOID_GAME:
        return Message("@XV",debugText:"Void Game");
      case MessageType.UNKNOWN:
        return Message("", debugText:"Unknown Message");
      default:
        return null;
    }
  }
//---------------------------------------------------
