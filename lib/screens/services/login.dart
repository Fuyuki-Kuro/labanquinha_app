import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:labanquinha_app/services/api_service.dart';
import 'package:labanquinha_app/widgets/diagonal_clipper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showStyledSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await ApiService.loginUser(
        phone: _phoneController.text,
        password: _passwordController.text,
      );

      // Guardar o token de forma segura
      await _storage.write(key: 'auth_token', value: token);

      if (mounted) {
        _showStyledSnackBar(context, 'Login bem-sucedido!');
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        _showStyledSnackBar(context, e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            ClipPath(
              clipper: DiagonalClipper(diagonalHeightFactor: 0.7),
              child: Container(
                height: screenHeight * 0.35,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF010101), Color(0xFF171616)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/images/pattern_mask.png'),
                    repeat: ImageRepeat.repeat,
                    opacity: 0.2,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, bottom: 1),
                      child: Text(
                        'LOGIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30.0),
                      child: Text(
                        'Artigos de Tabacaria',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(35.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        decoration: _buildInputDecoration('Telemóvel'),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty ? 'Por favor, digite o seu telemóvel' : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: _buildInputDecoration('Senha'),
                        validator: (value) => value == null || value.isEmpty ? 'Por favor, digite a sua senha' : null,
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Esqueceu a senha?', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF171616),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Entrar',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Não tem conta? ', style: TextStyle(color: Colors.black)),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pushNamed('/register'),
                            child: const Text(
                              'Registe-se',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1.0),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1.0),
      ),
    );
  }
}