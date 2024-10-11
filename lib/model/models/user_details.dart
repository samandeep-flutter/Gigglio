class UserDetails {
  final String? id;
  final String? username;
  final String? image;
  final String? email;
  final bool? verified;

  UserDetails({
    required this.id,
    required this.image,
    required this.username,
    required this.email,
    required this.verified,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'],
      image: json['image'],
      username: json['username'],
      email: json['email'],
      verified: json['verified'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'username': username,
        'email': email,
        'verified': verified,
      };

  UserDetails copyWith({
    String? id,
    String? username,
    String? image,
    String? email,
    bool? verified,
  }) {
    return UserDetails(
      id: id ?? this.id,
      image: image ?? this.image,
      username: username ?? this.username,
      email: email ?? this.email,
      verified: verified ?? this.verified,
    );
  }
}
