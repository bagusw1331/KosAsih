import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_text_link.dart';
import 'login_page.dart';

/// Halaman Daftar Akun Baru KosAsih.
///
/// Halaman ini dihubungkan ke [LoginKosAsihPage] lewat named route,
/// jadi user bisa bolak-balik Login <-> Register dalam satu aplikasi.
class RegisterKosAsihPage extends StatefulWidget {
  const RegisterKosAsihPage({super.key});

  /// Nama route, dipakai oleh `main.dart` dan halaman Login.
  static const String routeName = '/register';

  @override
  State<RegisterKosAsihPage> createState() => _RegisterKosAsihPageState();
}

class _RegisterKosAsihPageState extends State<RegisterKosAsihPage> {
  // Controller dibuat sekali di State (bukan di dalam build) supaya isi field
  // tidak ter-reset dan tidak bocor memorinya.
  final TextEditingController _nameController = TextEditingController(
    text: 'Bagus Wihandono',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'bagus@email.com',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '081234567890',
  );
  final TextEditingController _roomController = TextEditingController(
    text: 'Kamar A-04 (Lantai 1, AC)',
  );
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roomController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Nama, email, dan kata sandi wajib diisi.');
      return;
    }
    if (password.length < 8) {
      _showSnackBar('Kata sandi minimal 8 karakter.');
      return;
    }

    // TODO: ganti dengan proses registrasi (API / Firebase) saat sudah ada.
    _showSnackBar('Pendaftaran $email berhasil. Silakan masuk.');
    _backToLogin();
  }

  /// Kembali ke halaman login.
  ///
  /// Kalau halaman ini dibuka lewat `push` dari login, cukup `pop`.
  /// Kalau dibuka langsung (mis. deep link), ganti route ke login.
  void _backToLogin() {
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(LoginKosAsihPage.routeName);
    }
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // === Header ===
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: _backToLogin,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Kembali',
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Daftar Akun Baru',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // === Pilihan Role ===
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Daftar Sebagai',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLabel,
                    ),
                  ),
                  Text(
                    'Akses Penghuni',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Tab Pilihan: Penghuni Kos vs Pemilik Kos
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.tabBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: <Widget>[
                    // Tab Aktif (Penghuni Kos)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.person,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Penghuni Kos',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tab Non-Aktif (Pemilik Kos)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.domain,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Pemilik Kos',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // MORE_WIDGETS

              // === Form Input: Nama ===
              const Text(
                'Nama Lengkap',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _nameController,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // === Form Input: Email ===
              const Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // === Form Input: Nomor WhatsApp ===
              const Text(
                'Nomor WhatsApp',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _phoneController,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // === Form Pilihan Kamar ===
              const Row(
                children: <Widget>[
                  Text(
                    'Pilih Kamar ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '(Khusus Penghuni Kos)',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _roomController,
                prefixIcon: Icons.door_front_door_outlined,
                isPicker: true,
                readOnly: true,
              ),
              const SizedBox(height: 16),

              // === Form Input: Kata Sandi ===
              const Text(
                'Kata Sandi',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _passwordController,
                prefixIcon: Icons.lock_outline,
                hintText: 'Minimal 8 karakter',
                isPassword: true,
              ),
              const SizedBox(height: 20),

              // === Ketentuan / Checkbox ===
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Saya menyetujui ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4B5563),
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Syarat & Ketentuan ',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: 'sewa KosAsih.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // === Tombol Daftar Sekarang ===
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'DAFTAR SEKARANG',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // === Navigasi Bawah ke Login ===
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  AppTextLink(label: 'Masuk di sini', onTap: _backToLogin),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
