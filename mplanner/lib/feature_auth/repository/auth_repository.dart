import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/secure_storage_service.dart';
import '../data/auth_api.dart';
import '../models/auth_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: ref.watch(authApiProvider),
    storage: ref.watch(secureStorageProvider),
    tokenState: ref.watch(authTokenProvider.notifier),
  );
});

class AuthRepository {
  AuthRepository({
    required this.api,
    required this.storage,
    required this.tokenState,
  });

  final AuthApi api;
  final dynamic storage; // FlutterSecureStorage
  final StateController<String?> tokenState;

  static const _kTokenKey = 'auth_token';

  Future<AuthUser> login(String email, String password) async {
    final (user, token) = await api.login(email, password);
    await storage.write(key: _kTokenKey, value: token);
    tokenState.state = token;
    return user;
    }

  Future<void> logout() async {
    tokenState.state = null;
    await storage.delete(key: _kTokenKey);
  }

  Future<String?> loadToken() async {
    final t = await storage.read(key: _kTokenKey);
    tokenState.state = t;
    return t;
  }
}