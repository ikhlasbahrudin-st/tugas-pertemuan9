import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TampilanLogin extends StatefulWidget {
  const TampilanLogin({super.key});

  @override
  State<TampilanLogin> createState() => _TampilanLoginState();
}

class _TampilanLoginState extends State<TampilanLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _loading = false;

  String? _emailError;
  String? _passwordError;

  Future<void> _login() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Validasi kosong
    if (_emailController.text.isEmpty) {
      setState(() => _emailError = "Email wajib diisi");
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = "Password wajib diisi");
    }

    // Validasi format email
    if (_emailController.text.isNotEmpty &&
        !_emailController.text.contains(
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'),
        )) {
      setState(() => _emailError = "Format email tidak valid");
    }

    // Validasi panjang password minimal 6 karakter
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text.length < 6) {
      setState(() => _passwordError = "Password minimal 6 karakter");
    }

    if (_emailError != null || _passwordError != null) {
      return; // Stop login jika ada error
    }

    setState(() => _loading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Jika berhasil, bisa navigasi ke halaman utama
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login gagal')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Halaman Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: const OutlineInputBorder(),
                errorText: _emailError,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: const OutlineInputBorder(),
                errorText: _passwordError,
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _login, child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}
