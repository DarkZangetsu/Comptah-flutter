import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'entreprise_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Créer un compte' : 'Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ref.watch(authStateProvider).maybeWhen(
                loading: () => const CircularProgressIndicator(),
                orElse: () => ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text(_isSignUp ? 'Créer un compte' : 'Se connecter'),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                  });
                },
                child: Text(_isSignUp
                    ? 'Déjà un compte ? Se connecter'
                    : 'Pas de compte ? S\'inscrire'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_isSignUp) {
        await ref
            .read(authStateProvider.notifier)
            .signUp(_emailController.text, _passwordController.text);
        // Redirection après la création du compte
        setState(() {
          _isSignUp = false; // Passe à l'écran de connexion
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte créé avec succès ! Veuillez vous connecter.')),
        );
      } else {
        await ref
            .read(authStateProvider.notifier)
            .signIn(_emailController.text, _passwordController.text);
        // Redirection vers l'interface entreprise après connexion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EnterpriseSelectionScreen()),
        );
      }
    }
  }
}
