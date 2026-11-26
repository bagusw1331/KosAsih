import 'package:flutter/material.dart';

/// Satu komponen input yang dipakai bersama oleh halaman Login & Register.
///
/// Dengan menyatukan `InputDecoration` di sini:
/// - duplikasi kode form berkurang banyak,
/// - tampilan kedua halaman otomatis konsisten,
/// - perubahan desain cukup dilakukan di satu tempat.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.prefixIcon,
    this.hintText,
    this.labelText,
    this.keyboardType,
    this.isPassword = false,
    this.isPicker = false,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final IconData prefixIcon;
  final String? hintText;
  final String? labelText;
  final TextInputType? keyboardType;

  /// Jika `true`, teks disamarkan dan muncul tombol mata untuk melihat isinya.
  final bool isPassword;

  /// Jika `true`, muncul ikon panah ke bawah (field pilihan seperti "Kamar").
  final bool isPicker;

  /// Jika `true`, field hanya bisa dibaca (mis. hasil pilihan kamar).
  final bool readOnly;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      readOnly: widget.readOnly,
      obscureText: _obscure,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(widget.prefixIcon, size: 20),
        suffixIcon: _buildSuffixIcon(),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(color: const Color(0xFF1545C7)),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      );
    }
    if (widget.isPicker) {
      return const Icon(Icons.keyboard_arrow_down);
    }
    return null;
  }

  OutlineInputBorder _border({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color ?? Colors.grey.shade200),
    );
  }
}
