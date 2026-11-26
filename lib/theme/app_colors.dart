import 'package:flutter/material.dart';

/// Palet warna yang dipakai bersama oleh halaman Login dan Register.
///
/// Tujuan file ini: menyatukan "design language" kedua halaman supaya tidak
/// ada warna yang ditulis ulang (hardcode) di masing-masing file.
class AppColors {
  const AppColors._();

  /// Warna utama (biru) untuk tombol MASUK / DAFTAR.
  static const Color primary = Color(0xFF1545C7);

  /// Warna sekunder (teal) untuk teks penting seperti "Daftar Sekarang".
  static const Color secondary = Color(0xFF0F766E);

  /// Latar belakang lembut untuk icon/header.
  static const Color primarySoft = Color(0xFFEEF4FF);

  /// Warna teks judul.
  static const Color textPrimary = Color(0xFF111827);

  /// Warna teks label form.
  static const Color textLabel = Color(0xFF1F2937);

  /// Warna teks sekunder / keterangan.
  static const Color textSecondary = Color(0xFF6B7280);

  /// Latar belakang tab yang tidak aktif.
  static const Color tabBackground = Color(0xFFF3F4F6);
}
