import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
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
  bool _isPasswordVisible = false;

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
        title: Text(
          _isSignUp ? 'Créer un compte' : 'Connexion',
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xffea6b24),
        elevation: 0,
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ajout d'un espace pour centrer verticalement le contenu
                    const SizedBox(height: 50),
                    // Ajout du logo avec ajustement de sa taille
                    SizedBox(
                      height: 100, // Ajustez la hauteur selon votre préférence
                      child: Image.asset('images/Logo.png'),
                    ),
                    const SizedBox(height: 20),
                    // Texte de bienvenue
                    Text(
                      _isSignUp ? 'Bienvenue!' : 'Bienvenue à nouveau!',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isSignUp ? 'Créez votre compte' : 'Connectez-vous à votre compte',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Champ pour l'email
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    // Champ pour le mot de passe
                    _buildPasswordField(),
                    const SizedBox(height: 24),
                    // Bouton de soumission
                    _buildSubmitButton(),
                    const SizedBox(height: 16),
                    // Bouton pour basculer entre inscription et connexion
                    _buildToggleSignUpButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        prefixIcon: const Icon(Icons.lock),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      obscureText: !_isPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre mot de passe';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return ref.watch(authStateProvider).maybeWhen(
      loading: () => const CircularProgressIndicator(),
      orElse: () => ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xffea6b24),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
        ),
        onPressed: _handleSubmit,
        child: Text(
          _isSignUp ? 'Créer un compte' : 'Se connecter',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSignUpButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _isSignUp = !_isSignUp;
        });
      },
      child: Text(
        _isSignUp ? 'Déjà un compte ? Se connecter' : 'Pas de compte ? S\'inscrire',
        style: const TextStyle(color: Color(0xffea6b24)),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_isSignUp) {
        await ref.read(authStateProvider.notifier).signUp(
              _emailController.text,
              _passwordController.text,
            );
        setState(() {
          _isSignUp = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte créé avec succès ! Veuillez vous connecter.')),
        );
      } else {
        await ref.read(authStateProvider.notifier).signIn(
              _emailController.text,
              _passwordController.text,
            );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EnterpriseSelectionScreen()),
        );
      }
    }
  }
}
