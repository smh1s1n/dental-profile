import 'package:flutter_test/flutter_test.dart';
import 'package:dental_profile/core/services/auth_security_service.dart';

void main() {
  group('AuthSecurityService Singleton Tests', () {
    test('Ensures single instance across invocations', () {
      final a1 = AuthSecurityService.instance;
      final a2 = AuthSecurityService.instance;
      expect(identical(a1, a2), isTrue);
    });

    test('Doctor login with PIN 1234 sets Doctor session', () async {
      final auth = AuthSecurityService.instance;
      auth.logout();

      final success = await auth.loginWithPin('1234');
      expect(success, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentRole, equals(UserRole.doctor));
      expect(auth.currentSession?.isDoctor, isTrue);
    });

    test('Staff login with PIN 5678 sets Staff session', () async {
      final auth = AuthSecurityService.instance;
      auth.logout();

      final success = await auth.loginWithPin('5678');
      expect(success, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentRole, equals(UserRole.staff));
      expect(auth.currentSession?.isDoctor, isFalse);
    });

    test('Rejects invalid PIN code', () async {
      final auth = AuthSecurityService.instance;
      auth.logout();

      final success = await auth.loginWithPin('9999');
      expect(success, isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.currentSession, isNull);
    });
  });
}
