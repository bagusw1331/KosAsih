import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_text_link.dart';
import 'dashboard_pemilik_page.dart';
import 'register_page.dart';

/// Halaman Login KosAsih.
///
/// Halaman ini dihubungkan ke [RegisterKosAsihPage] lewat named route,
/// sehingga login dan register menjadi satu alur aplikasi (bukan dua app).
class LoginKosAsihPage extends StatefulWidget {
  const LoginKosAsihPage({super.key});

  /// Nama route, dipakai oleh `main.dart` dan halaman Register.
  static const String routeName = '/login';

  @override
  State<LoginKosAsihPage> createState() => _LoginKosAsihPageState();
}

class _LoginKosAsihPageState extends State<LoginKosAsihPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Email dan kata sandi wajib diisi.');
      return;
    }

    // TODO: ganti dengan proses autentikasi (API / Firebase) saat sudah ada.
    _showSnackBar('Login berhasil sebagai $email.');

    // Masuk ke dashboard setelah kredensial terisi.
    Navigator.of(
      context,
    ).pushReplacementNamed(DashboardPemilikPage.routeName);
  }

  /// Pindah ke halaman Daftar Akun.
  void _openRegisterPage() {
    Navigator.of(context).pushNamed(RegisterKosAsihPage.routeName);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 60),

              // === Header ===
              Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.home_filled,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'KosAsih',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manajemen Hunian Kos Terintegrasi',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // === Form Email ===
              const Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                hintText: 'Masukkan email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // === Form Kata Sandi ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Kata Sandi',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  AppTextLink(
                    label: 'Lupa Sandi?',
                    onTap: () =>
                        _showSnackBar('Fitur lupa sandi belum tersedia.'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _passwordController,
                prefixIcon: Icons.lock_outline,
                hintText: 'Masukkan kata sandi',
                isPassword: true,
              ),
              const SizedBox(height: 32),

              // === Tombol Masuk ===
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'MASUK',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // === Navigasi ke halaman Daftar ===
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('Belum punya akun? '),
                  AppTextLink(
                    label: 'Daftar Sekarang',
                    fontSize: 14,
                    onTap: _openRegisterPage,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
