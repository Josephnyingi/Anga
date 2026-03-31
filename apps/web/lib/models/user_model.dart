/// 👤 User Model
class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String preferredLocation;
  final bool notificationsEnabled;
  final bool darkModeEnabled;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.preferredLocation = 'Machakos, Kenya',
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['display_name'] ?? json['displayName'] ?? '',
      photoUrl: json['photo_url'] ?? json['photoUrl'],
      preferredLocation: json['preferred_location'] ?? 'Machakos, Kenya',
      notificationsEnabled: json['notifications_enabled'] ?? true,
      darkModeEnabled: json['dark_mode_enabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        'photo_url': photoUrl,
        'preferred_location': preferredLocation,
        'notifications_enabled': notificationsEnabled,
        'dark_mode_enabled': darkModeEnabled,
      };

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? preferredLocation,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, email: $email, displayName: $displayName)';
}
