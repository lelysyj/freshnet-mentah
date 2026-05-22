import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {

    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {

      /// REGISTER KE FIREBASE
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      _showTopNotification(
        "Registrasi berhasil. Silakan login.",
        isSuccess: true,
      );

      Future.delayed(const Duration(seconds: 1), () {

        if (mounted) {
          Navigator.pop(context);
        }
      });

    } on FirebaseAuthException catch (e) {

      String message = "Registrasi gagal";

      if (e.code == 'email-already-in-use') {
        message = "Email sudah digunakan";
      } else if (e.code == 'weak-password') {
        message = "Password terlalu lemah";
      } else if (e.code == 'invalid-email') {
        message = "Format email tidak valid";
      }

      _showTopNotification(
        message,
        isSuccess: false,
      );

    } finally {

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showTopNotification(
    String message, {
    bool isSuccess = false,
  }) {

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Row(
          children: [

            Icon(
              isSuccess
                  ? Icons.check_circle
                  : Icons.error,
              color: Colors.white,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        behavior: SnackBarBehavior.floating,

        margin: const EdgeInsets.only(
          top: 20,
          left: 16,
          right: 16,
          bottom: 620,
        ),

        backgroundColor: isSuccess
            ? Colors.green
            : Colors.red,

        duration: const Duration(seconds: 2),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {

    return InputDecoration(

      labelText: label,

      prefixIcon: Icon(icon),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF3F5F7),

      appBar: AppBar(
        title: const Text("Registrasi"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B3B78),
        elevation: 0,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Form(

          key: _formKey,

          child: Column(
            children: [

              const Icon(
                Icons.person_add_alt_1,
                size: 72,
                color: Color(0xFF0B3B78),
              ),

              const SizedBox(height: 12),

              const Text(
                "Buat Akun Baru",

                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B3B78),
                ),
              ),

              const SizedBox(height: 28),

              /// NAMA
              TextFormField(

                controller: _namaController,

                decoration: _inputDecoration(
                  "Nama Lengkap",
                  Icons.person,
                ),

                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Nama wajib diisi";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              /// EMAIL
              TextFormField(

                controller: _emailController,

                keyboardType: TextInputType.emailAddress,

                decoration: _inputDecoration(
                  "Email",
                  Icons.email,
                ),

                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Email wajib diisi";
                  }

                  if (!value.contains('@')) {
                    return "Format email tidak valid";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              /// TELEPON
              TextFormField(

                controller: _teleponController,

                keyboardType: TextInputType.phone,

                decoration: _inputDecoration(
                  "Nomor Telepon",
                  Icons.phone,
                ),

                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Nomor telepon wajib diisi";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              /// ALAMAT
              TextFormField(

                controller: _alamatController,

                decoration: _inputDecoration(
                  "Alamat",
                  Icons.home,
                ),

                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Alamat wajib diisi";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              /// USERNAME
              TextFormField(

                controller: _usernameController,

                decoration: _inputDecoration(
                  "Username",
                  Icons.account_circle,
                ),

                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Username wajib diisi";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              /// PASSWORD
              TextFormField(

                controller: _passwordController,

                obscureText: _obscurePassword,

                decoration: _inputDecoration(
                  "Password",
                  Icons.lock,
                ).copyWith(

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
                ),

                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Password wajib diisi";
                  }

                  if (value.length < 6) {
                    return "Password minimal 6 karakter";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              /// BUTTON REGISTER
              SizedBox(

                width: double.infinity,

                child: ElevatedButton(

                  onPressed: _isLoading
                      ? null
                      : _register,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B3B78),
                    foregroundColor: Colors.white,

                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "DAFTAR",

                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}