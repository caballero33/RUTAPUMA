class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'USER' or 'DRIVER'
  final DateTime createdAt;
  final String? assignedRoute;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.createdAt,
    this.assignedRoute,
  });

  // Convert UserModel to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      if (assignedRoute != null) 'assignedRoute': assignedRoute,
    };
  }

  // Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      assignedRoute: json['assignedRoute'] as String?,
    );
  }

  // Create a copy with modified fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? role,
    DateTime? createdAt,
    String? assignedRoute,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      assignedRoute: assignedRoute ?? this.assignedRoute,
    );
  }
}
