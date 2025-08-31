import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user_session.dart';

final authProvider = StateNotifierProvider<AuthNotifier, UserSession?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<UserSession?> {
  AuthNotifier() : super(null) {
    _loadSession();
  }

  final _sessionBox = Hive.box<UserSession>('session');

  Future<void> _loadSession() async {
    state = _sessionBox.get('user');
  }

  Future<bool> signInWithPhone(String phone) async {
    // Simulate phone validation (basic check for demo purposes)
    if (phone.isEmpty || phone.length < 10) {
      return false;
    }
    // Store phone in session (OTP verification will set loggedIn: true)
    final session = UserSession(phone: phone, loggedIn: false);
    await _sessionBox.put('user', session);
    state = session;
    return true;
  }

  Future<bool> verifyOtp(String otp) async {
    // Mock OTP: accept any 6-digit code
    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      return false;
    }
    final currentSession = state;
    if (currentSession == null) {
      return false;
    }
    // Update session to logged in
    final updatedSession = UserSession(phone: currentSession.phone, loggedIn: true);
    await _sessionBox.put('user', updatedSession);
    state = updatedSession;
    return true;
  }

  Future<void> signOut() async {
    await _sessionBox.delete('user');
    state = null;
  }
}