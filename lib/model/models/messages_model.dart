class MessagesModel {
  final List<String> users;
  final List<Messages> messages;

  MessagesModel({
    required List<String> users,
    this.messages = const [],
  }) : users = users.take(2).toList();

  // MessagesModel.withId({
  //   required this.to,
  //   this.messages = const [],
  // }) : users = null;

  factory MessagesModel.fromJson(Map<String, dynamic> json) {
    return MessagesModel(
      users: List<String>.from(json['users']),
      messages: List<Messages>.from(json['messages'].map((e) {
        return Messages.fromJson(e);
      })),
    );
  }

  Map<String, dynamic> toJson() => {
        'users': users,
        'messages': messages.map((e) => e.toJson()),
      };
}

class Messages {
  final String author;
  final String dateTime;
  final String message;

  const Messages({
    required this.author,
    required this.dateTime,
    required this.message,
  });

  factory Messages.fromJson(Map<String, dynamic> json) {
    return Messages(
      author: json['author'],
      dateTime: json['date_time'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
        'author': author,
        'date_time': dateTime,
        'message': message,
      };

  Messages copyWith({
    String? author,
    String? dateTime,
    String? message,
  }) {
    return Messages(
      author: author ?? this.author,
      dateTime: dateTime ?? this.dateTime,
      message: message ?? this.message,
    );
  }
}
