enum ChatMemberType { person, AI }

class ChatMessage {
  String? text;
  ChatMemberType? memberType;
  ChatMessage({required this.text, required this.memberType});
}
