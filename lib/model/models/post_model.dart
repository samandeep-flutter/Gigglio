class PostModel {
  final String author;
  final String? desc;
  final List<String> images;
  final String dateTime;
  final List<String> likes;
  final List<CommentModel> comments;

  const PostModel({
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
    required this.images,
    required this.dateTime,
  })  : likes = const [],
        comments = const [];

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
        author: json['author'],
        desc: json['desc'],
        images: List<String>.from(json['images']),
        dateTime: json['date_time'],
        likes: List<String>.from(json['likes']),
        comments: List.from(json['comments'].map((e) {
          return CommentModel.fromJson(e);
        })));
  }

  Map<String, dynamic> toJson() => {
        'author': author,
        'desc': desc,
        'images': images,
        'date_time': dateTime,
        'likes': likes,
        'comments': comments.map((e) => e.toJson()).toList(),
      };

  PostModel copyWith({
    String? author,
    String? desc,
    List<String>? images,
    String? dateTime,
    List<String>? likes,
    List<CommentModel>? comments,
  }) {
    return PostModel(
        author: author ?? this.author,
        desc: desc ?? this.desc,
        images: images ?? this.images,
        dateTime: dateTime ?? this.dateTime,
        likes: likes ?? this.likes,
        comments: comments ?? this.comments);
  }
}

class CommentModel {
  final String author;
  final String title;
  final String dateTime;

  const CommentModel({
    required this.author,
    required this.title,
    required this.dateTime,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
        author: json['author'],
        title: json['title'],
        dateTime: json['date_time']);
  }
  Map<String, dynamic> toJson() => {
        'author': author,
        'title': title,
        'date_time': dateTime,
      };
}
