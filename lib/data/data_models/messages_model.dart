import 'package:equatable/equatable.dart';
import 'package:gigglio/data/data_models/user_details.dart';

class MessagesDbModel extends Equatable {
  final List<String> users;
  final List<UserData> userData;
  final DateTime? lastUpdated;
  final List<Messages> messages;

  const MessagesDbModel({
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
      messages: List<Messages>.from(json['messages'].map((e) {
        return Messages.fromJson(e);
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
    List<UserData>? userData,
    DateTime? lastUpdated,
    List<Messages>? messages,
  }) {
    return MessagesDbModel(
      users: users,
      userData: userData ?? this.userData,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [users, userData, lastUpdated, messages];
}

class MessagesModel extends Equatable {
  final UserDetails user;
  final List<UserData> userData;
  final DateTime? lastUpdated;
  final List<Messages> messages;

  const MessagesModel({
    required this.user,
    required this.userData,
    required this.lastUpdated,
    required this.messages,
  });

  @override
  List<Object?> get props => [user, userData, lastUpdated, messages];
}

class Messages extends Equatable {
  final String author;
  final DateTime dateTime;
  final String text;
  final double? scrollAt;
  final int position;

  const Messages({
    required this.author,
    required this.dateTime,
    required this.text,
    required this.scrollAt,
    required this.position,
  });

  factory Messages.fromJson(Map<String, dynamic> json) {
    return Messages(
        author: json['author'],
        dateTime: DateTime.parse(json['date_time']),
        text: json['text'],
        scrollAt: json['scroll_at']?.toDouble(),
        position: json['position']);
  }

  Map<String, dynamic> toJson() => {
        'author': author,
        'date_time': dateTime.toIso8601String(),
        'text': text,
        'position': position,
        'scroll_at': scrollAt?.toDouble(),
      };

  Messages copyWith({
    String? author,
    DateTime? dateTime,
    String? text,
    int? position,
    double? scrollAt,
  }) {
    return Messages(
      author: author ?? this.author,
      dateTime: dateTime ?? this.dateTime,
      text: text ?? this.text,
      position: position ?? this.position,
      scrollAt: scrollAt ?? this.scrollAt,
    );
  }

  @override
  List<Object?> get props => [author, dateTime, text, scrollAt, position];
}

class UserData {
  final String id;
  DateTime? seen;
  double? scrollAt;

  UserData({required this.id, required this.seen, required this.scrollAt});

  UserData.newUser(this.id)
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
}
