import 'package:gigglio/model/models/user_details.dart';

class PostModel {
  final UserDetails author;
  final String? desc;
  final List<String> images;
  final String dateTime;
  final List<UserDetails> likes;
  final List<CommentModel> comments;

  PostModel({
    required this.author,
    required this.desc,
    required this.images,
    required this.dateTime,
    required this.likes,
    required this.comments,
  });

  PostModel.add({
    required this.author,
    required this.desc,
    required this.images,
    required this.dateTime,
  })  : likes = [],
        comments = [];

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
        author: UserDetails.fromJson(json['author']),
        desc: json['desc'],
        images: List<String>.from(json['images']),
        dateTime: json['date_time'],
        likes: List.from(json['likes'].map((e) => UserDetails.fromJson(e))),
        comments:
            List.from(json['comments'].map((e) => UserDetails.fromJson(e))));
  }

  Map<String, dynamic> toJson() => {
        'author': author.toJson(),
        'desc': desc,
        'images': images,
        'date_time': dateTime,
        'likes': likes.map((e) => e.toJson()).toList(),
        'comments': comments.map((e) => e.toJson()).toList(),
      };
}

class CommentModel {
  final UserDetails author;
  final String title;
  final DateTime dateTime;

  CommentModel({
    required this.author,
    required this.title,
    required this.dateTime,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
        author: UserDetails.fromJson(json['author']),
        title: json['title'],
        dateTime: json['date_time']);
  }
  Map<String, dynamic> toJson() => {'author': author.toJson()};
}
