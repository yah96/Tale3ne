class Chats {
  final String id;
  final String fromId;
  final String fromName;
  final String toId;
  final String toName;
  final int seconds;
  final int nanoseconds;
  final String lastMessage;

  Chats({
    required this.id,
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.seconds,
    required this.nanoseconds,
    required this.lastMessage,
  });

  factory Chats.fromJson(Map<String, dynamic> json) {
    final addtime = json['addtime'] as Map<String, dynamic>;
    return Chats(
      id: json['_id'],
      fromId: json['from_ID'],
      fromName: json['from_name'],
      toId: json['to_ID'],
      toName: json['to_name'],
      seconds: addtime['_seconds'],
      nanoseconds: addtime['_nanoseconds'],
      lastMessage: json['lastMessage'],
    );
  }
}
