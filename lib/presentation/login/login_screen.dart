import 'package:flutter/material.dart';
import '../../controller/auth/auth_controller.dart'; // Pastikan ini mengarah ke AuthController yang benar

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = AuthController();
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username dan password wajib diisi!")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String? token = await _authController.login(username, password);

    setState(() {
      _isLoading = false;
    });

    if (token != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login berhasil!")),
      );

      // Simpan token ke penyimpanan lokal (SharedPreferences)
      // Lalu arahkan ke halaman dashboard
      Navigator.pushNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login gagal, cek kembali username/password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 100.0),
                child: Image.asset(
                  'assets/LogoAlphaOmega.jpeg',
                  fit: BoxFit.contain,
                  width: 400,
                  height: 400,
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 350.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      child: TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          labelText: 'Username',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: 400,
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _login,
                            child: const Text('Login'),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
