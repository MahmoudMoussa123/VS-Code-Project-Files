import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_user.dart';

final authApiProvider = Provider<AuthApi>((_) => AuthApi());

class AuthApi {
  Future<(AuthUser,String)> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return (
      AuthUser(id: 'u-${email.hashCode}', email: email, displayName: email.split('@').first),
      'mock_token_${DateTime.now().millisecondsSinceEpoch}'
    );
  }

  Future<AuthUser> refresh(String token) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return AuthUser(id: 'u_refresh', email: 'ref@example.com');
  }
}