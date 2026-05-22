import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login berhasil'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, '/home');

    } on FirebaseAuthException catch (e) {

      String message = 'Login gagal';

      if (e.code == 'user-not-found') {
        message = 'User tidak ditemukan';
      } else if (e.code == 'wrong-password') {
        message = 'Password salah';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),

      body: SafeArea(
        child: SingleChildScrollView(

          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 24),

              /// LOGO
              Center(
                child: Container(
                  width: 82,
                  height: 82,

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0D1B3E),
                        Color(0xFF1A4FA0),
                      ],
                    ),

                    borderRadius: BorderRadius.circular(24),
                  ),

                  child: const Icon(
                    Icons.set_meal,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// TITLE
              const Center(
                child: Text(
                  'FRESHNET',

                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0D1B3E),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  'Sistem deteksi kesegaran ikan berbasis AI',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7A90),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              /// CARD LOGIN
              Container(

                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'Masuk ke Akun',

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// EMAIL
                    TextField(

                      controller: _emailCtrl,

                      decoration: InputDecoration(
                        hintText: 'Email',

                        prefixIcon: const Icon(Icons.email),

                        filled: true,
                        fillColor: const Color(0xFFF7F9FC),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// PASSWORD
                    TextField(

                      controller: _passwordCtrl,

                      obscureText: _obscurePassword,

                      decoration: InputDecoration(
                        hintText: 'Password',

                        prefixIcon: const Icon(Icons.lock),

                        suffixIcon: IconButton(

                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),

                          onPressed: () {

                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),

                        filled: true,
                        fillColor: const Color(0xFFF7F9FC),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// BUTTON LOGIN
                    SizedBox(

                      width: double.infinity,

                      child: ElevatedButton(

                        onPressed: _isLoading
                            ? null
                            : _handleLogin,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D1B3E),

                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),

                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('LOGIN'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// REGISTER LINK
                    Row(

                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        const Text('Belum punya akun?'),

                        TextButton(

                          onPressed: () {

                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },

                          child: const Text('Daftar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}