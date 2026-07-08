class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.lastMessage,
    required this.lastTime,
    required this.unread,
  });

  final String id;
  final String name;
  final String subtitle;
  final String lastMessage;
  final String lastTime;
  final int unread;

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastTime: json['lastTime'] as String? ?? '',
      unread: (json['unread'] as num?)?.toInt() ?? 0,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.time,
    required this.isMe,
  });

  final String id;
  final String sender;
  final String text;
  final String time;
  final bool isMe;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      sender: json['sender'] as String,
      text: json['text'] as String,
      time: json['time'] as String? ?? '',
      isMe: json['isMe'] as bool? ?? false,
    );
  }
}

class CommunityData {
  const CommunityData({required this.rooms, required this.messagesByRoom});

  final List<ChatRoom> rooms;
  final Map<String, List<ChatMessage>> messagesByRoom;

  factory CommunityData.fromJson(Map<String, dynamic> json) {
    final msgs = json['messages'] as Map<String, dynamic>? ?? {};
    return CommunityData(
      rooms: (json['rooms'] as List<dynamic>)
          .map((e) => ChatRoom.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      messagesByRoom: msgs.map(
        (k, v) => MapEntry(
          k,
          (v as List<dynamic>).map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList(growable: false),
        ),
      ),
    );
  }
}
