class MessagesModel {
  final List<UserData> users;
  final String? lastUpdated;
  final List<Messages> messages;

  MessagesModel({
    required List<UserData> users,
    this.lastUpdated,
    this.messages = const [],
  }) : users = users.take(2).toList();

  factory MessagesModel.fromJson(Map<String, dynamic> json) {
    return MessagesModel(
      users: List<UserData>.from(json['users'].map((e) {
        return UserData.fromJson(e);
      })),
      lastUpdated: json['last_updated'],
      messages: List<Messages>.from(json['messages'].map((e) {
        return Messages.fromJson(e);
      })),
    );
  }

  Map<String, dynamic> toJson() => {
        'users': users.map((e) => e.toJson()),
        'last_updated': lastUpdated,
        'messages': messages.map((e) => e.toJson()),
      };

  MessagesModel copyWith({
    List<UserData>? users,
    String? lastUpdated,
    List<Messages>? messages,
  }) {
    return MessagesModel(
      users: users ?? this.users,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      messages: messages ?? this.messages,
    );
  }
}

class Messages {
  final String author;
  final String dateTime;
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
        dateTime: json['date_time'],
        text: json['text'],
        scrollAt: json['scroll_at']?.toDouble(),
        position: json['position']);
  }

  Map<String, dynamic> toJson() => {
        'author': author,
        'date_time': dateTime,
        'text': text,
        'position': position,
        'scroll_at': scrollAt?.toDouble(),
      };

  Messages copyWith({
    String? author,
    String? dateTime,
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
}

class UserData {
  final String id;
  int seen;
  double? scrollAt;

  UserData({required this.id, required this.seen, required this.scrollAt});

  UserData.newUser(this.id)
      : seen = 0,
        scrollAt = null;

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      seen: json['seen'],
      scrollAt: json['scroll_at']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'seen': seen,
        'scroll_at': scrollAt?.toDouble(),
      };

  UserData copyWith({String? id, int? seen, double? scrollAt}) {
    return UserData(
      id: id ?? this.id,
      seen: seen ?? this.seen,
      scrollAt: scrollAt ?? this.scrollAt,
    );
  }
}
