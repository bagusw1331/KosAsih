import 'dart:io';

class RepositoryException implements Exception {
  const RepositoryException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => message;
}

class FileUploadValidator {
  const FileUploadValidator._();

  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

  static void validate(
    File file, {
    List<String> allowedExtensions = const ['jpg', 'jpeg', 'png', 'pdf'],
  }) {
    if (!file.existsSync()) {
      throw const RepositoryException('File tidak ditemukan di perangkat.');
    }

    final fileName = file.path.split(Platform.pathSeparator).last;
    final dotIndex = fileName.lastIndexOf('.');
    final ext = dotIndex != -1
        ? fileName.substring(dotIndex + 1).toLowerCase()
        : '';

    if (!allowedExtensions.contains(ext)) {
      final formatLabel = allowedExtensions
          .map((e) => e.toUpperCase())
          .join(', ');
      throw RepositoryException(
        'Format file tidak didukung. Gunakan format $formatLabel.',
      );
    }

    final sizeInBytes = file.lengthSync();
    if (sizeInBytes > maxFileSizeBytes) {
      throw const RepositoryException(
        'Ukuran file melebihi batas maksimal 5 MB.',
      );
    }
  }
}
