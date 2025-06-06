import 'package:equatable/equatable.dart';
import 'package:gigglio/data/data_models/post_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';

class MessagesDbModel extends Equatable {
  final String? id;
  final List<String> users;
  final List<UserData> userData;
  final DateTime? lastUpdated;
  final List<MessagesDb> messages;

  const MessagesDbModel({
    this.id,
    required this.users,
    required this.userData,
    this.lastUpdated,
    this.messages = const [],
  });

  factory MessagesDbModel.fromJson(Map<String, dynamic> json) {
    return MessagesDbModel(
      users: List<String>.from(json['users']),
      userData: List<UserData>.from(json['user_data'].map((e) {
        return UserData.fromJson(e);
      })),
      lastUpdated: DateTime.tryParse(json['last_updated'] ?? ''),
      messages: List<MessagesDb>.from(json['messages'].map((e) {
        return MessagesDb.fromJson(e);
      })),
    );
  }

  Map<String, dynamic> toJson() => {
        'users': users,
        'last_updated': lastUpdated?.toIso8601String(),
        'user_data': userData.map((e) => e.toJson()),
        'messages': messages.map((e) => e.toJson()),
      };

  MessagesDbModel copyWith({
    String? id,
    List<UserData>? userData,
    DateTime? lastUpdated,
    List<MessagesDb>? messages,
  }) {
    return MessagesDbModel(
      users: users,
      id: id ?? this.id,
      userData: userData ?? this.userData,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [id, users, userData, lastUpdated, messages];
}

class MessagesModel extends Equatable {
  final String? id;
  final UserDetails user;
  final List<UserData> userData;
  final DateTime? lastUpdated;
  final List<MessagesDb> messages;

  const MessagesModel({
    required this.id,
    required this.user,
    required this.userData,
    required this.lastUpdated,
    required this.messages,
  });

  factory MessagesModel.fromDB(
      {required UserDetails user, required MessagesDbModel model}) {
    return MessagesModel(
        user: user,
        id: model.id,
        userData: model.userData,
        lastUpdated: model.lastUpdated,
        messages: model.messages);
  }

  @override
  List<Object?> get props => [id, user, userData, lastUpdated, messages];
}

class MessagesDb extends Equatable {
  final String author;
  final DateTime dateTime;
  final String? text;
  final String? post;
  final double? scrollAt;

  const MessagesDb({
    required this.author,
    required this.dateTime,
    required this.text,
    required this.post,
    required this.scrollAt,
  });

  const MessagesDb.text({
    required this.author,
    required this.dateTime,
    required this.text,
    required this.scrollAt,
  }) : post = null;

  const MessagesDb.post({
    required this.author,
    required this.dateTime,
    required this.post,
  })  : text = null,
        scrollAt = null;

  factory MessagesDb.fromJson(Map<String, dynamic> json) {
    return MessagesDb(
      author: json['author'],
      dateTime: DateTime.parse(json['date_time']),
      text: json['text'],
      post: json['post'],
      scrollAt: json['scroll_at']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'author': author,
        'date_time': dateTime.toIso8601String(),
        'text': text,
        'post': post,
        'scroll_at': scrollAt?.toDouble(),
      };

  MessagesDb copyWith({
    String? author,
    DateTime? dateTime,
    String? text,
    String? post,
    double? scrollAt,
  }) {
    return MessagesDb(
      author: author ?? this.author,
      dateTime: dateTime ?? this.dateTime,
      text: text ?? this.text,
      post: post ?? this.post,
      scrollAt: scrollAt ?? this.scrollAt,
    );
  }

  @override
  List<Object?> get props => [author, dateTime, text, post, scrollAt];
}

class Messages extends Equatable {
  final String author;
  final DateTime dateTime;
  final String? text;
  final PostModel? post;
  final double? scrollAt;

  const Messages({
    required this.author,
    required this.dateTime,
    required this.text,
    required this.post,
    required this.scrollAt,
  });

  factory Messages.fromDb({PostModel? post, required MessagesDb db}) {
    return Messages(
      author: db.author,
      dateTime: db.dateTime,
      text: db.text,
      post: post,
      scrollAt: db.scrollAt,
    );
  }

  factory Messages.fromJson(Map<String, dynamic> json) {
    return Messages(
      author: json['author'],
      dateTime: DateTime.parse(json['date_time']),
      text: json['text'],
      post: json['post'] != null ? PostModel.fromJson(json['post']) : null,
      scrollAt: json['scroll_at']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'author': author,
        'date_time': dateTime.toIso8601String(),
        'text': text,
        'post': post?.toJson(),
        'scroll_at': scrollAt?.toDouble(),
      };

  @override
  List<Object?> get props => [author, dateTime, text, post, scrollAt];
}

class UserData extends Equatable {
  final String id;
  final DateTime? seen;
  final double? scrollAt;

  const UserData(
      {required this.id, required this.seen, required this.scrollAt});

  const UserData.newUser(this.id)
      : seen = null,
        scrollAt = null;

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
        id: json['id'],
        seen: DateTime.tryParse(json['seen'] ?? ''),
        scrollAt: json['scroll_at']?.toDouble());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'seen': seen?.toIso8601String(),
        'scroll_at': scrollAt?.toDouble()
      };

  UserData copyWith({String? id, DateTime? seen, double? scrollAt}) {
    return UserData(
      id: id ?? this.id,
      seen: seen ?? this.seen,
      scrollAt: scrollAt ?? this.scrollAt,
    );
  }

  @override
  List<Object?> get props => [id, seen, scrollAt];
}
