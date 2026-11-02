import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_security_service.dart';

final authServiceProvider = Provider<AuthSecurityService>((ref) {
  return AuthSecurityService.instance;
});

class AuthStateNotifier extends Notifier<AuthSession?> {
  @override
  AuthSession? build() {
    return ref.watch(authServiceProvider).currentSession;
  }

  Future<bool> loginWithPin(String pin) async {
    final authService = ref.read(authServiceProvider);
    final success = await authService.loginWithPin(pin);
    if (success) {
      state = authService.currentSession;
    }
    return success;
  }

  void logout() {
    ref.read(authServiceProvider).logout();
    state = null;
  }
}

final authStateNotifierProvider = NotifierProvider<AuthStateNotifier, AuthSession?>(AuthStateNotifier.new);
