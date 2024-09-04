class Message {
  final String id; // The unique ID for the message
  final String userId; // The user ID associated with the message
  final int seconds; // The seconds part of the message's timestamp
  final int nanoseconds; // The nanoseconds part of the message's timestamp
  final String content; // The content of the message
  final String senderName;

  Message({
    required this.id,
    required this.userId,
    required this.seconds,
    required this.nanoseconds,
    required this.content,
    this.senderName = '',
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    final addtime = json['addtime'];
    print(json);
    return Message(
      id: json['_id'],
      userId: json['UID'],
      seconds: addtime['_seconds'],
      nanoseconds: addtime['_nanoseconds'],
      content: json['content'],
      senderName: json['senderName'] ?? '',
    );
  }
}
