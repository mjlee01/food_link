class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final String foodItemId;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.foodItemId,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'foodItemId': foodItemId,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
      id: id,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      foodItemId: map['foodItemId'] ?? '',
      timestamp:
          map['timestamp'] != null
              ? DateTime.parse(map['timestamp'])
              : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }
}
