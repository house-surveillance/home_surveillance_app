class NotificationModel {
  final String id;
  final String type;
  final String message;
  final String? imageUrl;
  final String? imageId;

  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    required this.imageUrl,
    required this.imageId,
    required this.timestamp,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      type: json['type'] ?? 'No type provided',
      message: json['message'] ?? 'No message provided',
      imageUrl: json['imageUrl'],
      imageId: json['imageId'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
