import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../controller/auth/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = AuthController();

  bool _isLoading = false;
  bool _obscure = true;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final u = _usernameController.text.trim();
    final p = _passwordController.text.trim();

    if (u.isEmpty || p.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan password wajib diisi!')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 🔹 Jika login sebagai admin (bypass backend)
      if (u == "admin" && p == "admin") {
        final box = GetStorage();
        await box.write("id_user", "0"); // bisa pakai id fiktif
        await box.write("role", "admin");
        await box.write("token", "dummy-token-admin");

        debugPrint("✅ Login sebagai ADMIN");

        Navigator.pushReplacementNamed(context, '/dashboard');
        setState(() => _isLoading = false);
        return;
      }

      // 🔹 Selain admin → cek ke backend
      final result = await _authController.login(u, p);

      if (result != null) {
        final token = result['token'];
        final user = result['user'];

        final idUser = user['id_user'];
        final role = user['role'];

        debugPrint("✅ Login berhasil. id_user=$idUser role=$role token=$token");

        final box = GetStorage();
        await box.write("id_user", idUser);
        await box.write("role", role);
        await box.write("token", token);

        // 🔹 Arahkan ke chooseRole
        Navigator.pushReplacementNamed(
          context,
          '/chooseRole',
          arguments: {"id_user": idUser, "role": role, "token": token},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login gagal. Cek username/password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth >= 900;

            return Stack(
              children: [
                // Dekorasi blob
                Positioned(top: -100, right: -120, child: _blob(240)),
                Positioned(bottom: -120, left: -100, child: _blob(200)),

                if (isWide) _buildWideLayout(c.maxWidth, c.maxHeight),
                if (!isWide) _buildMobileLayout(),
              ],
            );
          },
        ),
      ),
    );
  }

  /// ====== DESKTOP/TABLET LAYOUT ======
  Widget _buildWideLayout(double maxW, double maxH) {
    final cardW = maxW.clamp(900, 1100);
    final formMaxWidth = 420.0;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: cardW.toDouble(), minHeight: 520),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade700, Colors.blue.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          bottomLeft: Radius.circular(28),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/logoalphaomegapng.png',
                                width: 160),
                            const SizedBox(height: 20),
                            const Text(
                              "Alpha Omega",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: formMaxWidth),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome Back 👋",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 30),
                              _form(contentOnBlue: false),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ====== MOBILE LAYOUT ======
  Widget _buildMobileLayout() {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.06,
            child: Center(
              child: Image.asset('assets/LogoAlphaOmega.jpeg',
                  fit: BoxFit.contain),
            ),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.18),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _form(contentOnBlue: false),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ====== FORM ======
  Widget _form({required bool contentOnBlue}) {
    final titleColor = contentOnBlue ? Colors.white : Colors.blue.shade800;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Login',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: titleColor,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: _usernameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person),
            labelText: 'Username',
            filled: true,
            fillColor: Colors.blue.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordController,
          obscureText: _obscure,
          onSubmitted: (_) => _login(),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              tooltip: _obscure ? 'Tampilkan password' : 'Sembunyikan password',
            ),
            labelText: 'Password',
            filled: true,
            fillColor: Colors.blue.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
      ],
    );
  }

  /// ====== BLOB ======
  Widget _blob(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.6),
            Colors.blue.shade100.withOpacity(0.15),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
