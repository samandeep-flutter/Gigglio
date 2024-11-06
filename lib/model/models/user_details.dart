class UserDetails {
  final String id;
  final String displayName;
  final String? image;
  final String email;
  final String? bio;
  final bool? verified;

  const UserDetails({
    required this.id,
    required this.image,
    required this.displayName,
    required this.email,
    required this.verified,
    this.bio,
  });

  const UserDetails.blank()
      : id = '',
        image = null,
        displayName = '',
        email = '',
        bio = null,
        verified = false;

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'],
      image: json['image'],
      displayName: json['display_name'],
      email: json['email'],
      bio: json['bio'],
      verified: json['verified'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'display_name': displayName,
        'email': email,
        'bio': bio,
        'verified': verified,
      };

  UserDetails copyWith({
    String? id,
    String? displayName,
    String? image,
    String? email,
    String? bio,
    bool? verified,
  }) {
    return UserDetails(
      id: id ?? this.id,
      image: image ?? this.image,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      bio: bio ?? this.bio,
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
      verified: details?.verified ?? verified,
    );
  }
}
