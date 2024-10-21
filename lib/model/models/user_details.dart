class UserDetails {
  final String id;
  final String displayName;
  final String? image;
  final String email;
  final bool? verified;

  UserDetails({
    required this.id,
    required this.image,
    required this.displayName,
    required this.email,
    required this.verified,
  });

  UserDetails.blank()
      : id = '',
        image = null,
        displayName = '',
        email = '',
        verified = false;

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'],
      image: json['image'],
      displayName: json['display_name'],
      email: json['email'],
      verified: json['verified'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'display_name': displayName,
        'email': email,
        'verified': verified,
      };

  UserDetails copyWith({
    String? id,
    String? displayName,
    String? image,
    String? email,
    bool? verified,
  }) {
    return UserDetails(
      id: id ?? this.id,
      image: image ?? this.image,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      verified: verified ?? this.verified,
    );
  }
}
