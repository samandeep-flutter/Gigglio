class UserDetails {
  final String id;
  final String displayName;
  final String? image;
  final String email;
  final List<String> friends;
  final List<String> requests;
  final String? bio;
  final int? notiSeen;
  final bool? login;
  final bool? verified;

  const UserDetails({
    required this.id,
    required this.image,
    required this.displayName,
    required this.email,
    required this.verified,
    required this.login,
    this.bio,
    this.notiSeen,
    this.friends = const [],
    this.requests = const [],
  });

  const UserDetails.blank()
      : id = '',
        image = null,
        displayName = '',
        email = '',
        bio = null,
        notiSeen = 0,
        friends = const [],
        requests = const [],
        login = false,
        verified = false;

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'],
      image: json['image'],
      displayName: json['display_name'],
      email: json['email'],
      bio: json['bio'],
      notiSeen: json['noti_seen_count'],
      friends: List<String>.from(json['friends'] ?? []),
      requests: List<String>.from(json['requests'] ?? []),
      login: json['login'],
      verified: json['verified'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'display_name': displayName,
        'email': email,
        'bio': bio,
        'noti_seen_count': notiSeen,
        'friends': friends,
        'requests': requests,
        'login': login,
        'verified': verified,
      };

  UserDetails copyWith({
    String? id,
    String? displayName,
    String? image,
    String? email,
    String? bio,
    int? notiSeen,
    List<String>? friends,
    List<String>? requests,
    bool? login,
    bool? verified,
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
      verified: verified ?? this.verified,
    );
  }

  UserDetails copyFrom({required UserDetails? details}) {
    return UserDetails(
      id: details?.id ?? id,
      image: details?.image ?? image,
      displayName: details?.displayName ?? displayName,
      email: details?.email ?? email,
      bio: details?.bio ?? bio,
      notiSeen: details?.notiSeen ?? notiSeen,
      friends: details?.friends ?? friends,
      requests: details?.requests ?? requests,
      login: details?.login ?? login,
      verified: details?.verified ?? verified,
    );
  }
}
