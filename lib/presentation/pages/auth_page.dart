import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    final auth = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              const Icon(Icons.menu_book_rounded, size: 80, color: AppColors.primary),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Manga Reader',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Votre bibliothèque de mangas',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Toggle Login / Register
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: Row(
                  children: [
                    _TabButton(label: 'Connexion', selected: _isLogin, onTap: () => setState(() => _isLogin = true)),
                    _TabButton(label: 'Inscription', selected: !_isLogin, onTap: () => setState(() => _isLogin = false)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildField(
                      controller: _usernameCtrl,
                      label: 'Nom d\'utilisateur',
                      icon: Icons.person_outline,
                      validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (!_isLogin) ...[
                      _buildField(
                        controller: _emailCtrl,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Champ requis';
                          if (!v.contains('@')) return 'Email invalide';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    _buildField(
                      controller: _passwordCtrl,
                      label: 'Mot de passe',
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Champ requis';
                        if (!_isLogin && v.length < 6) return 'Minimum 6 caractères';
                        return null;
                      },
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: AppSpacing.md),
                      _buildField(
                        controller: _confirmCtrl,
                        label: 'Confirmer le mot de passe',
                        icon: Icons.lock_outline,
                        obscure: true,
                        validator: (v) => v != _passwordCtrl.text ? 'Les mots de passe ne correspondent pas' : null,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              ElevatedButton(
                onPressed: auth.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: auth.isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : Text(_isLogin ? 'SE CONNECTER' : 'S\'INSCRIRE'),
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text('OU', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              OutlinedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).continueAsGuest();
                  context.go('/');
                },
                icon: const Icon(Icons.person_outline),
                label: const Text('CONTINUER SANS COMPTE'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'En continuant, vous acceptez nos conditions d\'utilisation',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authProvider.notifier);
    bool success;

    if (_isLogin) {
      success = await notifier.login(_usernameCtrl.text.trim(), _passwordCtrl.text);
    } else {
      success = await notifier.register(
        _usernameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
    }

    if (success && mounted) context.go('/');
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
              color: selected ? Colors.white : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }
}