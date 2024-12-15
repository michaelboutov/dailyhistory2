import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.imageUrl,
    this.likeCount = 0,
  });

  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String? imageUrl;
  final int likeCount;

  factory Article.fromMap(Map<String, dynamic> data, String id) {
    return Article(
      id: id,
      title: data['title'] as String,
      content: data['content'] as String,
      date: (data['date'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] as String?,
      likeCount: data['likeCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'likeCount': likeCount,
    };
  }

  Article copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    String? imageUrl,
    int? likeCount,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      likeCount: likeCount ?? this.likeCount,
    );
  }
}
