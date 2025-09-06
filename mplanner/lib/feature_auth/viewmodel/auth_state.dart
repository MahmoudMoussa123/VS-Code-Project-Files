import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/auth_user.dart';
part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.unauthenticated() = _Unauth;
  const factory AuthState.authenticating() = _Authenticating;
  const factory AuthState.authenticated(AuthUser user) = _Authd;
  const factory AuthState.failure(String message) = _Failure;
}