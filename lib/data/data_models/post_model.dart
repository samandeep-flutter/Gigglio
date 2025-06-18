import 'package:equatable/equatable.dart';
import 'package:gigglio/data/data_models/user_details.dart';

class PostDbModel extends Equatable {
  final String? id;
  final String author;
  final String? desc;
  final List<String> images;
  final DateTime dateTime;
  final List<String> likes;
  final List<CommentDbModel> comments;

  const PostDbModel({
    required this.id,
    required this.author,
    required this.desc,
    required this.images,
    required this.dateTime,
    required this.likes,
    required this.comments,
  });

  const PostDbModel.add({
    required this.author,
    required this.desc,
    required this.dateTime,
  })  : id = null,
        images = const [],
        likes = const [],
        comments = const [];

  factory PostDbModel.fromJson(Map<String, dynamic> json) {
    return PostDbModel(
        id: json['id'],
        author: json['author'],
        desc: json['desc'],
        images: List<String>.from(json['images']),
        dateTime: DateTime.parse(json['date_time']),
        likes: List<String>.from(json['likes']),
        comments: List.from(json['comments'].map((e) {
          return CommentDbModel.fromJson(e);
        })));
  }

  Map<String, dynamic> toJson() => {
        'author': author,
        'images': images,
        if (desc != null) 'desc': desc,
        'date_time': dateTime.toIso8601String(),
        'likes': likes,
        'comments': comments.map((e) => e.toJson()).toList(),
      };

  PostDbModel copyWith({
    String? id,
    String? desc,
    List<String>? images,
    DateTime? dateTime,
    List<String>? likes,
    List<CommentDbModel>? comments,
  }) {
    return PostDbModel(
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

class PostModel extends Equatable {
  final String? id;
  final UserDetails author;
  final String? desc;
  final List<String> images;
  final DateTime dateTime;
  final List<String> likes;
  final List<CommentDbModel> comments;

  const PostModel({
    required this.id,
    required this.author,
    required this.desc,
    required this.images,
    required this.dateTime,
    required this.likes,
    required this.comments,
  });

  factory PostModel.fromDb(
      {required UserDetails user, required PostDbModel post}) {
    return PostModel(
        id: post.id,
        author: user,
        desc: post.desc,
        images: post.images,
        dateTime: post.dateTime,
        likes: post.likes,
        comments: post.comments);
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      author: UserDetails.fromJson(json['author']),
      desc: json['desc'],
      images: List<String>.from(json['images']),
      dateTime: DateTime.parse(json['date_time']),
      likes: List<String>.from(json['likes']),
      comments: List.from(json['comments'].map((e) {
        return CommentDbModel.fromJson(e);
      })),
    );
  }

  Map<String, dynamic> toJson() => {
        'author': author.toJson(),
        'desc': desc,
        'images': images,
        'date_time': dateTime.toIso8601String(),
        'likes': likes,
        'comments': comments.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props =>
      [id, author, desc, images, dateTime, likes, comments];
}

class CommentDbModel extends Equatable {
  final String author;
  final String title;
  final DateTime dateTime;

  const CommentDbModel({
    required this.author,
    required this.title,
    required this.dateTime,
  });

  factory CommentDbModel.fromJson(Map<String, dynamic> json) {
    return CommentDbModel(
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

class CommentModel extends Equatable {
  final UserDetails author;
  final String title;
  final DateTime dateTime;

  const CommentModel({
    required this.author,
    required this.title,
    required this.dateTime,
  });

  factory CommentModel.fromDb(UserDetails author,
      {required CommentDbModel comment}) {
    return CommentModel(
      author: author,
      title: comment.title,
      dateTime: comment.dateTime,
    );
  }

  @override
  List<Object?> get props => [author, title, dateTime];
}
