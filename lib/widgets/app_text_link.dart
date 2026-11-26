import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Teks yang bisa ditekan, dipakai untuk navigasi antar halaman auth
/// (mis. "Daftar Sekarang" di Login dan "Masuk di sini" di Register).
///
/// Tujuannya supaya gaya link di kedua halaman identik dan hanya ditulis sekali.
class AppTextLink extends StatelessWidget {
  const AppTextLink({
    super.key,
    required this.label,
    required this.onTap,
    this.fontSize = 13,
  });

  final String label;
  final VoidCallback onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: AppColors.secondary,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
