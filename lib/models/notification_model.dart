class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
        'createdAt': createdAt,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: json['createdAt'] as String,
      );
}
