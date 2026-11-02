import 'dart:convert';
import 'package:crypto/crypto.dart';

enum UserRole {
  guest,
  staff, // Compounder / Chamber Manager
  doctor, // Dr. Syed Tanvir Rahman
}

class AuthSession {
  final String userId;
  final String name;
  final UserRole role;
  final DateTime loginTime;
  final String token;

  AuthSession({
    required this.userId,
    required this.name,
    required this.role,
    required this.loginTime,
    required this.token,
  });

  bool get isDoctor => role == UserRole.doctor;
  bool get isStaff => role == UserRole.staff || role == UserRole.doctor;
}

/// Singleton pattern service for secure PIN-based authentication,
/// role verification, and session lifecycle.
class AuthSecurityService {
  AuthSecurityService._internal();

  static AuthSecurityService? _instance;

  static AuthSecurityService get instance {
    _instance ??= AuthSecurityService._internal();
    return _instance!;
  }

  AuthSession? _currentSession;

  AuthSession? get currentSession => _currentSession;
  bool get isAuthenticated => _currentSession != null;
  UserRole get currentRole => _currentSession?.role ?? UserRole.guest;

  // Hashed PINs for security
  // Doctor PIN default: 1234
  // Compounder PIN default: 5678
  static const String _doctorPinHash = '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4'; // sha256('1234')
  static const String _staffPinHash = 'f8638b979b2f4f793ddb6dbd197e0ee25a7a6ea32b0ae22f5e3c5d119d839e75'; // sha256('5678')

  String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  /// Authenticate with PIN
  Future<bool> loginWithPin(String pin) async {
    final hash = _hashPin(pin);
    
    // Doctor check (1234)
    if (hash == _doctorPinHash) {
      _currentSession = AuthSession(
        userId: 'DOC-01',
        name: 'Dr. Syed Tanvir Rahman',
        role: UserRole.doctor,
        loginTime: DateTime.now(),
        token: 'SESSION-${DateTime.now().millisecondsSinceEpoch}',
      );
      return true;
    }

    // Compounder / Chamber Staff check (5678)
    if (hash == _staffPinHash) {
      _currentSession = AuthSession(
        userId: 'STAFF-01',
        name: 'Md. Rafiqul Islam (Senior Compounder)',
        role: UserRole.staff,
        loginTime: DateTime.now(),
        token: 'SESSION-${DateTime.now().millisecondsSinceEpoch}',
      );
      return true;
    }

    return false;
  }

  /// Logout current session
  void logout() {
    _currentSession = null;
  }
}
