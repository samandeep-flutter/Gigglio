import 'package:equatable/equatable.dart';

class PostModel extends Equatable {
  final String? id;
  final String author;
  final String? desc;
  final List<String> images;
  final DateTime dateTime;
  final List<String> likes;
  final List<CommentModel> comments;

  const PostModel({
    required this.id,
    required this.author,
    required this.desc,
    required this.images,
    required this.dateTime,
    required this.likes,
    required this.comments,
  });

  const PostModel.add({
    required this.author,
    required this.desc,
    required this.dateTime,
  })  : id = null,
        images = const [],
        likes = const [],
        comments = const [];

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
        id: json['id'],
        author: json['author'],
        desc: json['desc'],
        images: List<String>.from(json['images']),
        dateTime: DateTime.parse(json['date_time']),
        likes: List<String>.from(json['likes']),
        comments: List.from(json['comments'].map((e) {
          return CommentModel.fromJson(e);
        })));
  }

  Map<String, dynamic> toJson() => {
        'author': author,
        'desc': desc,
        'images': images,
        'date_time': dateTime.toIso8601String(),
        'likes': likes,
        'comments': comments.map((e) => e.toJson()).toList(),
      };

  PostModel copyWith({
    String? id,
    String? desc,
    List<String>? images,
    DateTime? dateTime,
    List<String>? likes,
    List<CommentModel>? comments,
  }) {
    return PostModel(
        author: author,
        id: id ?? this.id,
        desc: desc ?? this.desc,
        images: images ?? this.images,
        dateTime: dateTime ?? this.dateTime,
        likes: likes ?? this.likes,
        comments: comments ?? this.comments);
  }

  @override
  List<Object?> get props =>
      [id, author, desc, images, dateTime, likes, comments];
}

class CommentModel extends Equatable {
  final String author;
  final String title;
  final DateTime dateTime;

  const CommentModel({
    required this.author,
    required this.title,
    required this.dateTime,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
        author: json['author'],
        title: json['title'],
        dateTime: DateTime.parse(json['date_time']));
  }
  Map<String, dynamic> toJson() => {
        'author': author,
        'title': title,
        'date_time': dateTime.toIso8601String()
      };

  @override
  List<Object?> get props => [author, title, dateTime];
}
