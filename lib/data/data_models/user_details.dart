import 'package:equatable/equatable.dart';

class UserDetails extends Equatable {
  final String id;
  final String displayName;
  final String? image;
  final String email;
  final List<String> friends;
  final List<String> requests;
  final DateTime notiSeen;
  final String? bio;
  final bool? login;
  final String? deviceToken;

  const UserDetails({
    required this.id,
    required this.image,
    required this.displayName,
    required this.email,
    required this.login,
    required this.deviceToken,
    this.bio,
    required this.notiSeen,
    this.friends = const [],
    this.requests = const [],
  });
  const UserDetails.profile({
    required this.id,
    required this.image,
    required this.displayName,
    required this.email,
    required this.notiSeen,
    this.bio,
  })  : friends = const [],
        requests = const [],
        login = true,
        deviceToken = null;

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'],
      image: json['image'],
      displayName: json['display_name'],
      email: json['email'],
      bio: json['bio'],
      notiSeen: DateTime.parse(json['noti_seen']),
      friends: List<String>.from(json['friends']),
      requests: List<String>.from(json['requests']),
      deviceToken: json['device_token'],
      login: json['login'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'display_name': displayName,
        'email': email,
        'bio': bio,
        'noti_seen': notiSeen.toIso8601String(),
        'friends': friends,
        'requests': requests,
        'login': login,
        'device_token': deviceToken,
      };

  UserDetails copyWith({
    String? id,
    String? displayName,
    String? image,
    String? email,
    String? bio,
    DateTime? notiSeen,
    List<String>? friends,
    List<String>? requests,
    bool? login,
    String? deviceToken,
  }) {
    return UserDetails(
      id: id ?? this.id,
      image: image ?? this.image,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      notiSeen: notiSeen ?? this.notiSeen,
      friends: friends ?? this.friends,
      requests: requests ?? this.requests,
      login: login ?? this.login,
      deviceToken: deviceToken ?? this.deviceToken,
    );
  }

  UserDetails copyFrom({required UserDetails? details}) {
    return UserDetails(
      id: details?.id ?? id,
      image: details?.image ?? image,
      displayName: details?.displayName ?? displayName,
      email: details?.email ?? email,
      bio: details?.bio ?? bio,
      friends: details?.friends ?? friends,
      requests: details?.requests ?? requests,
      login: details?.login ?? login,
      deviceToken: details?.deviceToken ?? deviceToken,
      notiSeen: details?.notiSeen ?? notiSeen,
    );
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        image,
        email,
        bio,
        notiSeen,
        friends,
        requests,
        login,
        deviceToken
      ];
}
