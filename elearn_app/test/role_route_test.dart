import 'package:elearn_app/core/auth/role_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('admin resolves to admin dashboard route', () {
    expect(resolveHomeRoute('admin'), AppHomeRoute.admin);
  });

  test('faculty and teacher resolve to faculty route', () {
    expect(resolveHomeRoute('faculty'), AppHomeRoute.faculty);
    expect(resolveHomeRoute('teacher'), AppHomeRoute.faculty);
  });

  test('invalid role falls back to login', () {
    expect(resolveHomeRoute('unknown'), AppHomeRoute.login);
    expect(resolveHomeRoute(null), AppHomeRoute.login);
  });
}
