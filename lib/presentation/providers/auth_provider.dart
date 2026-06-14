import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(userRepositoryProvider));
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isGuest;

  AuthState({this.user, this.isLoading = false, this.error, this.isGuest = false});

  AuthState copyWith({User? user, bool? isLoading, String? error, bool? isGuest}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  bool get isAuthenticated => user != null;
  String get displayName => user?.username ?? 'Invité';
}

class AuthNotifier extends StateNotifier<AuthState> {
  final UserRepository _repo;

  AuthNotifier(this._repo) : super(AuthState());

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // On utilise username comme email pour Supabase
      final user = await _repo.login(email: username, password: password);
      if (user != null) {
        state = state.copyWith(user: user, isLoading: false, isGuest: false);
        return true; // Succès !
      } else {
        state = state.copyWith(error: 'Utilisateur non trouvé', isLoading: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.register(email: email, password: password, username: username);
      if (user != null) {
        state = state.copyWith(user: user, isLoading: false, isGuest: false);
        return true; // Succès !
      } else {
        state = state.copyWith(error: 'Erreur lors de l\'inscription', isLoading: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = state.copyWith(user: null, isGuest: false);
  }

  Future<void> checkLogin() async {
    final user = await _repo.getCurrentUser();
    if (user != null) {
      state = state.copyWith(user: user, isGuest: false);
    } else {
      state = state.copyWith(user: null);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void continueAsGuest() {
    state = state.copyWith(isGuest: true);
  }
}