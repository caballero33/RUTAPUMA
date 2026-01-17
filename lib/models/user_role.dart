/// User roles in the RUTAPUMA app
enum UserRole {
  user,   // Student user who tracks buses
  driver, // Bus driver who shares location
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'Estudiante';
      case UserRole.driver:
        return 'Conductor';
    }
  }
  
  String get description {
    switch (this) {
      case UserRole.user:
        return 'Rastrea tu bus en tiempo real';
      case UserRole.driver:
        return 'Comparte tu ubicación';
    }
  }
}
