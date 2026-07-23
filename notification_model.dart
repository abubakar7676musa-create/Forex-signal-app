class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? signalId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.signalId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      signalId: json['signal_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
