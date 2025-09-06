import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/auth_repository.dart';
import 'auth_state.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref.watch(authRepositoryProvider));
});

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel(this._repo) : super(const AuthState.unauthenticated());
  final AuthRepository _repo;

  Future<void> login(String email, String password) async {
    state = const AuthState.authenticating();
    try {
      final user = await _repo.login(email, password);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = const AuthState.failure('Login failed');
    }
  }

  Future<void> logout() => _repo.logout();
}