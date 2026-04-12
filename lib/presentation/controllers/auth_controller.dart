import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(userRepositoryProvider));
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).isAuthenticated;
});

class AuthState {
  final bool isAuthenticated;
  final String? username;
  final bool isGuest;
  final String? errorMessage;

  AuthState({
    this.isAuthenticated = false,
    this.username,
    this.isGuest = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? username,
    bool? isGuest,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      isGuest: isGuest ?? this.isGuest,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final UserRepository _userRepository;

  AuthController(this._userRepository) : super(AuthState());

  Future<bool> register(String username, String email, String password) async {
    try {
      final existingUser = await _userRepository.getUserByUsername(username);
      if (existingUser != null) {
        state = state.copyWith(errorMessage: 'Ce nom d\'utilisateur existe déjà');
        return false;
      }

      final existingEmail = await _userRepository.getUserByEmail(email);
      if (existingEmail != null) {
        state = state.copyWith(errorMessage: 'Cet email est déjà utilisé');
        return false;
      }

      final newUser = User(
        username: username,
        email: email,
        passwordHash: _hashPassword(password),
        createdAt: DateTime.now(),
      );

      await _userRepository.saveUser(newUser);

      state = AuthState(
        isAuthenticated: true,
        username: username,
        isGuest: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erreur lors de l\'inscription');
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final user = await _userRepository.getUserByUsername(username);

      if (user == null) {
        state = state.copyWith(errorMessage: 'Utilisateur non trouvé');
        return false;
      }

      if (!_verifyPassword(password, user.passwordHash)) {
        state = state.copyWith(errorMessage: 'Mot de passe incorrect');
        return false;
      }

      state = AuthState(
        isAuthenticated: true,
        username: username,
        isGuest: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erreur lors de la connexion');
      return false;
    }
  }

  void continueAsGuest() {
    state = AuthState(
      isAuthenticated: false,
      username: null,
      isGuest: true,
    );
  }

  void logout() {
    state = AuthState();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  String _hashPassword(String password) {
    return password;
  }

  bool _verifyPassword(String password, String storedHash) {
    return _hashPassword(password) == storedHash;
  }
}