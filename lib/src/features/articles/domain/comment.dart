import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  Comment({
    required this.id,
    required this.articleId,
    required this.userId,
    required this.userDisplayName,
    required this.text,
    required this.timestamp,
  });

  final String id;
  final String articleId;
  final String userId;
  final String userDisplayName;
  final String text;
  final DateTime timestamp;

  factory Comment.fromMap(Map<String, dynamic> data, String id) {
    return Comment(
      id: id,
      articleId: data['articleId'] as String,
      userId: data['userId'] as String,
      userDisplayName: data['userDisplayName'] as String,
      text: data['text'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'articleId': articleId,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
