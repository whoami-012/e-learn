enum AppHomeRoute {
  login,
  student,
  faculty,
  admin,
}

AppHomeRoute resolveHomeRoute(String? role) {
  switch ((role ?? '').toLowerCase()) {
    case 'student':
      return AppHomeRoute.student;
    case 'faculty':
    case 'teacher':
      return AppHomeRoute.faculty;
    case 'admin':
      return AppHomeRoute.admin;
    default:
      return AppHomeRoute.login;
  }
}

bool canAccessAdmin(String? role) => resolveHomeRoute(role) == AppHomeRoute.admin;

bool canAccessFaculty(String? role) {
  final route = resolveHomeRoute(role);
  return route == AppHomeRoute.faculty;
}
