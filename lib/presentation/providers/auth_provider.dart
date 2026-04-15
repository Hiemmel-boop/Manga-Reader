import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/logger.dart';

// État d'authentification
class AuthState {
  final User? user;
  final bool isGuest;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isGuest = false,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;
  String get displayName => user?.username ?? (isGuest ? 'Invité' : '');

  AuthState copyWith({
    User? user,
    bool? isGuest,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isGuest: isGuest ?? this.isGuest,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(userRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final UserRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final user = await _repo.getCurrentUser();
      if (user != null) {
        state = AuthState(user: user);
      }
    } catch (e) {
      appLogger.e('_restoreSession', error: e);
    }
  }

  Future<bool> register(String username, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.register(
        username: username,
        email: email,
        password: password,
      );
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.login(username: username, password: password);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  void continueAsGuest() {
    state = const AuthState(isGuest: true);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}