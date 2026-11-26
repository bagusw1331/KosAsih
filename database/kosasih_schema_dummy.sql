-- ============================================================================
-- KosAsih Database Schema & Dummy Data (MySQL 8.0+ / MariaDB 10.4+)
-- Database: kosasih
-- Sesuai dengan model & tampilan Flutter KosAsih (Mode Pemilik & Penghuni)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS `kosasih`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `kosasih`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `kostASIH_tr_notifikasi`;
DROP TABLE IF EXISTS `kostASIH_md_panduan`;
DROP TABLE IF EXISTS `kostASIH_tr_tamu_izin`;
DROP TABLE IF EXISTS `kostASIH_tr_pengumuman`;
DROP TABLE IF EXISTS `kostASIH_tr_komplain`;
DROP TABLE IF EXISTS `kostASIH_tr_pembayaran`;
DROP TABLE IF EXISTS `kostASIH_tr_hunian`;
DROP TABLE IF EXISTS `kostASIH_md_pengaturan`;
DROP TABLE IF EXISTS `kostASIH_md_kamar`;
DROP TABLE IF EXISTS `kostASIH_md_user`;

SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------------------------------------------------------
-- 1. Master User (Pemilik & Penghuni Kos)
-- ----------------------------------------------------------------------------
CREATE TABLE `kostASIH_md_user` (
  `id_user` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nama_user` VARCHAR(100) NOT NULL,
  `email` VARCHAR(120) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `no_wa` VARCHAR(25) NOT NULL,
  `kontak_darurat` VARCHAR(80) NULL,
  `pekerjaan` VARCHAR(80) NULL,
  `role` ENUM('pemilik', 'penghuni') NOT NULL DEFAULT 'penghuni',
  `fcm_token` VARCHAR(255) NULL,
  `status_akun` ENUM('aktif', 'nonaktif') NOT NULL DEFAULT 'aktif',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_user`),
  UNIQUE KEY `uq_user_email` (`email`),
  KEY `idx_user_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 2. Master Kamar
-- ----------------------------------------------------------------------------
CREATE TABLE `kostASIH_md_kamar` (
  `id_kamar` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nomor_kamar` VARCHAR(20) NOT NULL,
  `lantai` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `tipe_kamar` VARCHAR(120) NOT NULL,
  `harga_sewa` INT UNSIGNED NOT NULL DEFAULT 1200000,
  `fasilitas` TEXT NOT NULL,
  `status_kamar` ENUM('siap_huni', 'terisi', 'perbaikan') NOT NULL DEFAULT 'siap_huni',
  `catatan_kondisi` TEXT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_kamar`),
  UNIQUE KEY `uq_kamar_nomor` (`nomor_kamar`),
  KEY `idx_kamar_status` (`status_kamar`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 3. Transaksi Hunian (Relasi Penghuni <-> Kamar & Status Sewa)
-- ----------------------------------------------------------------------------
CREATE TABLE `kostASIH_tr_hunian` (
  `id_hunian` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_user` INT UNSIGNED NOT NULL,
  `id_kamar` INT UNSIGNED NOT NULL,
  `tgl_mulai_sewa` DATE NOT NULL,
  `tgl_selesai_sewa` DATE NULL,
  `status_sewa` ENUM('sewa_aktif', 'terlambat_bayar', 'sedang_mudik', 'check_out') NOT NULL DEFAULT 'sewa_aktif',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_hunian`),
  KEY `idx_hunian_user` (`id_user`),
  KEY `idx_hunian_kamar` (`id_kamar`),
  KEY `idx_hunian_status` (`status_sewa`),
  CONSTRAINT `fk_hunian_user` FOREIGN KEY (`id_user`) REFERENCES `kostASIH_md_user` (`id_user`) ON DELETE CASCADE,
  CONSTRAINT `fk_hunian_kamar` FOREIGN KEY (`id_kamar`) REFERENCES `kostASIH_md_kamar` (`id_kamar`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 4. Master Pengaturan Kos, Rekening, QRIS & Aturan Denda Otomatis
-- ----------------------------------------------------------------------------
CREATE TABLE `kostASIH_md_pengaturan` (
  `id_pengaturan` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nama_kos` VARCHAR(100) NOT NULL,
  `nama_pemilik` VARCHAR(100) NOT NULL,
  `email_pemilik` VARCHAR(120) NOT NULL,
  `no_wa_pemilik` VARCHAR(25) NOT NULL,
  `nama_bank` VARCHAR(50) NOT NULL,
  `nomor_rekening` VARCHAR(40) NOT NULL,
  `atas_nama_rekening` VARCHAR(120) NOT NULL,
  `nmid_qris` VARCHAR(60) NULL,
  `denda_otomatis_aktif` TINYINT(1) NOT NULL DEFAULT 1,
  `tgl_jatuh_tempo_bulanan` TINYINT UNSIGNED NOT NULL DEFAULT 10,
  `tarif_denda_harian` INT UNSIGNED NOT NULL DEFAULT 20000,
  `batas_toleransi_hari` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `jadwal_notifikasi_fcm` VARCHAR(80) NOT NULL DEFAULT 'H-3 & H-1 via FCM',
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_pengaturan`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 5. Transaksi Pembayaran, Tagihan, Denda & Verifikasi Bukti Bayar
-- ----------------------------------------------------------------------------
CREATE TABLE `kostASIH_tr_pembayaran` (
  `id_pembayaran` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `kode_invoice` VARCHAR(30) NOT NULL,
  `id_kamar` INT UNSIGNED NOT NULL,
  `id_user` INT UNSIGNED NOT NULL,
  `periode_pembayaran` VARCHAR(40) NOT NULL,
  `tenggat_pembayaran` DATE NOT NULL,
  `nominal_pembayaran` INT UNSIGNED NOT NULL,
  `biaya_tamu_pembayaran` INT UNSIGNED NOT NULL DEFAULT 0,
  `denda_pembayaran` INT UNSIGNED NOT NULL DEFAULT 0,
  `hari_terlambat` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `denda_dibebaskan` TINYINT(1) NOT NULL DEFAULT 0,
  `metode_pembayaran` ENUM('Transfer Bank BCA', 'Transfer Bank Mandiri', 'QRIS Instan') NULL,
  `bukti_pembayaran` VARCHAR(255) NULL,
  `kuitansi_pembayaran` VARCHAR(255) NULL,
  `status_pembayaran` ENUM('belum_bayar', 'menunggu_verifikasi', 'terlambat', 'lunas', 'ditolak') NOT NULL DEFAULT 'belum_bayar',
  `alasan_penolakan` TEXT NULL,
  `tgl_unggah_bukti` DATETIME NULL,
  `tgl_lunas_pembayaran` DATETIME NULL,
  `diverifikasi_oleh` INT UNSIGNED NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_pembayaran`),
  UNIQUE KEY `uq_pembayaran_invoice` (`kode_invoice`),
  KEY `idx_pembayaran_kamar` (`id_kamar`),
  KEY `idx_pembayaran_user` (`id_user`),
  KEY `idx_pembayaran_status` (`status_pembayaran`),
  CONSTRAINT `fk_pembayaran_kamar` FOREIGN KEY (`id_kamar`) REFERENCES `kostASIH_md_kamar` (`id_kamar`) ON DELETE CASCADE,
  CONSTRAINT `fk_pembayaran_user` FOREIGN KEY (`id_user`) REFERENCES `kostASIH_md_user` (`id_user`) ON DELETE CASCADE,
  CONSTRAINT `fk_pembayaran_verifikator` FOREIGN KEY (`diverifikasi_oleh`) REFERENCES `kostASIH_md_user` (`id_user`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 6. Transaksi Komplain & Aduan Fasilitas
-- ----------------------------------------------------------------------------
CREATE TABLE `kostASIH_tr_komplain` (
  `id_komplain` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_user` INT UNSIGNED NOT NULL,
  `id_kamar` INT UNSIGNED NOT NULL,
  `kategori_fasilitas` VARCHAR(80) NOT NULL,
  `prioritas` ENUM('Normal', 'Prioritas Tinggi') NOT NULL DEFAULT 'Normal',
  `judul_komplain` VARCHAR(150) NOT NULL,
  `deskripsi_komplain` TEXT NOT NULL,
  `foto_komplain` VARCHAR(255) NULL,
  `catatan_komplain` TEXT NULL,
  `status_komplain` ENUM('menunggu', 'sedang_diperbaiki', 'selesai') NOT NULL DEFAULT 'menunggu',
  `tgl_komplain` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tgl_selesai` DATETIME NULL,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_komplain`),
  KEY `idx_komplain_user` (`id_user`),
  KEY `idx_komplain_kamar` (`id_kamar`),
  KEY `idx_komplain_status` (`status_komplain`),
  CONSTRAINT `fk_komplain_user` FOREIGN KEY (`id_user`) REFERENCES `kostASIH_md_user` (`id_user`) ON DELETE CASCADE,
  CONSTRAINT `fk_komplain_kamar` FOREIGN KEY (`id_kamar`) REFERENCES `kostASIH_md_kamar` (`id_kamar`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 7. Pengumuman & Siaran Massal
-- ----------------------------------------------------------------------------
CREATE TABLE `kostASIH_tr_pengumuman` (
  `id_pengumuman` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_penulis` INT UNSIGNED NOT NULL,
  `judul_pengumuman` VARCHAR(150) NOT NULL,
  `isi_pengumuman` TEXT NOT NULL,
  `kategori_pengumuman` VARCHAR(60) NOT NULL DEFAULT 'Informasi Umum',
  `pin_pengumuman` TINYINT(1) NOT NULL DEFAULT 0,
  `tgl_pengumuman` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_pengumuman`),
  KEY `idx_pengumuman_pin` (`pin_pengumuman`),
  CONSTRAINT `fk_pengumuman_penulis` FOREIGN KEY (`id_penulis`) REFERENCES `kostASIH_md_user` (`id_user`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 8. Laporan Tamu Menginap & Izin Mudik
-- ----------------------------------------------------------------------------
CREATE TABLE `kostASIH_tr_tamu_izin` (
  `id_tamu` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_user` INT UNSIGNED NOT NULL,
  `id_kamar` INT UNSIGNED NOT NULL,
  `jenis_laporan` ENUM('tamu_menginap', 'izin_mudik') NOT NULL,
  `nama_tamu` VARCHAR(100) NULL,
  `jumlah_tamu` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `lama_menginap_malam` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `biaya_tamu` INT UNSIGNED NOT NULL DEFAULT 0,
  `tgl_mulai` DATE NOT NULL,
  `tgl_selesai` DATE NOT NULL,
  `keterangan` TEXT NULL,
  `status_izin` ENUM('menunggu', 'disetujui', 'selesai', 'ditolak') NOT NULL DEFAULT 'disetujui',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_tamu`),
  KEY `idx_tamu_user` (`id_user`),
  KEY `idx_tamu_kamar` (`id_kamar`),
  CONSTRAINT `fk_tamu_user` FOREIGN KEY (`id_user`) REFERENCES `kostASIH_md_user` (`id_user`) ON DELETE CASCADE,
  CONSTRAINT `fk_tamu_kamar` FOREIGN KEY (`id_kamar`) REFERENCES `kostASIH_md_kamar` (`id_kamar`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 9. Master Panduan & Tata Tertib Kos
-- ----------------------------------------------------------------------------
CREATE TABLE `kostASIH_md_panduan` (
  `id_panduan` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `judul_panduan` VARCHAR(120) NOT NULL,
  `kategori_panduan` VARCHAR(60) NOT NULL,
  `isi_panduan` TEXT NOT NULL,
  `urutan` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_panduan`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 10. Notifikasi & Log Aktivitas
-- ----------------------------------------------------------------------------
CREATE TABLE `kostASIH_tr_notifikasi` (
  `id_notifikasi` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_user_tujuan` INT UNSIGNED NOT NULL,
  `judul` VARCHAR(150) NOT NULL,
  `pesan` TEXT NOT NULL,
  `tipe` ENUM('pembayaran', 'komplain', 'pengumuman', 'denda', 'tamu') NOT NULL,
  `target_id` INT UNSIGNED NULL,
  `sudah_dibaca` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_notifikasi`),
  KEY `idx_notif_user` (`id_user_tujuan`, `sudah_dibaca`),
  CONSTRAINT `fk_notif_user` FOREIGN KEY (`id_user_tujuan`) REFERENCES `kostASIH_md_user` (`id_user`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- DATA DUMMY (Sinkron dengan seluruh tampilan & BLoC KosAsih)
-- Password contoh (bcrypt dari "secretPassword123"):
-- $2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi
-- ============================================================================

INSERT INTO `kostASIH_md_user`
  (`id_user`, `nama_user`, `email`, `password_hash`, `no_wa`, `kontak_darurat`, `pekerjaan`, `role`, `fcm_token`, `status_akun`)
VALUES
  (1,  'Bu Asih',         'admin.buasih@kosasih.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+62 811-9234-8899', NULL,                     'Pemilik Kos',     'pemilik',  'fcm_pemilik_buasih_001',   'aktif'),
  (10, 'Nadia Putri',     'nadia@email.com',          '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0812-3344-5566',    'Ibu: 0812-1122-3344',    'Mahasiswi',       'penghuni', 'fcm_penghuni_nadia_010',   'aktif'),
  (12, 'Bagus Wihandono', 'bagus@email.com',          '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0812-8821-9012',    'Ortu: 0813-9021-8899',   'Mahasiswa',       'penghuni', 'fcm_penghuni_bagus_012',   'aktif'),
  (13, 'Dimas Anggara',   'dimas@email.com',          '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0857-1123-8890',    'Ibu: 0856-7788-9900',    'Karyawan Swasta', 'penghuni', 'fcm_penghuni_dimas_013',   'aktif'),
  (14, 'Andi Pratama',    'andi@email.com',           '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0821-9988-1234',    NULL,                     'Mhs. Teknik',     'penghuni', 'fcm_penghuni_andi_014',    'aktif'),
  (15, 'Raka Pratama',    'raka@email.com',           '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0813-4455-6677',    'Ayah: 0813-2233-4455',   'Karyawan IT',     'penghuni', 'fcm_penghuni_raka_015',    'aktif'),
  (16, 'Fajar Nugraha',   'fajar@email.com',          '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0852-6677-8899',    'Ortu: 0852-1100-2200',   'Mahasiswa',       'penghuni', 'fcm_penghuni_fajar_016',   'aktif'),
  (17, 'Siti Sarah',      'siti@email.com',           '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '0878-5544-3322',    'Ibu: 0878-1122-0099',    'Mahasiswi',       'penghuni', 'fcm_penghuni_siti_017',    'aktif');

INSERT INTO `kostASIH_md_kamar`
  (`id_kamar`, `nomor_kamar`, `lantai`, `tipe_kamar`, `harga_sewa`, `fasilitas`, `status_kamar`, `catatan_kondisi`)
VALUES
  (1,  'A-08', 1, 'KosAsih Residence Sayap Timur',     1200000, 'AC 1/2 PK, KM Dalam & Shower, Kasur Springbed No. 2, Wi-Fi 50 Mbps, Lemari Pakaian', 'siap_huni', 'Siap Huni: Bersih & Kunci Tersedia di Kantor (Tidak ada kerusakan fisik).'),
  (2,  'A-02', 1, 'Lantai 1 • Kamar Standar AC',       1200000, 'AC, KM Dalam, Kasur Springbed, Wi-Fi',                                              'terisi',    'Kondisi Prima: Seluruh fasilitas berfungsi normal.'),
  (3,  'A-06', 1, 'Lantai 1 • Kamar Utama AC',         1200000, 'AC, KM Dalam, Kasur Springbed, Wi-Fi',                                              'terisi',    'Kondisi Prima: Seluruh fasilitas berfungsi normal.'),
  (4,  'A-04', 1, 'Kamar Utama AC • Lt 1',             1200000, 'AC, KM Dalam, Kasur Springbed, Wi-Fi',                                              'terisi',    'AC Tidak Dingin & Menetes ke lantai. Teknisi AC dijadwalkan datang hari ini pukul 14.00 WIB.'),
  (5,  'B-01', 2, 'Lantai 2 • Balkon Luar',            1200000, 'AC, KM Dalam, Kasur Springbed, Meja Kerja, Balkon Luar',                            'terisi',    'Kondisi Prima: Seluruh fasilitas dan kelistrikan berfungsi dengan normal.'),
  (6,  'B-03', 2, 'Lantai 2 • Sayap Barat',            1200000, 'AC, KM Dalam, Kasur Springbed, Wi-Fi',                                              'terisi',    'Penghuni sedang izin mudik s.d. 20 Okt 2026.'),
  (7,  'B-04', 2, 'Lantai 2 • Kamar Utama AC',         1200000, 'AC, KM Dalam, Kasur Springbed, Wi-Fi',                                              'terisi',    'Kondisi Prima: Seluruh fasilitas berfungsi normal.'),
  (8,  'B-02', 2, 'Lantai 2 • Kamar Standar AC',       1200000, 'AC, KM Dalam, Kasur Springbed, Wi-Fi',                                              'terisi',    'Seal keran wastafel baru diganti, berfungsi normal.'),
  (9,  'B-09', 2, 'KosAsih Sayap Barat (View Taman)',  1200000, 'AC 1/2 PK, KM Dalam, Meja Belajar & Kursi, Kasur Springbed, Wi-Fi',                 'siap_huni', 'Siap Huni: Sirkulasi Udara Bagus, Jendela Menghadap Taman & Kolam Ikan.'),
  (10, 'C-01', 2, 'Lantai 2 • Sayap Selatan',          1200000, 'AC, KM Dalam, Kasur Springbed, Wi-Fi',                                              'terisi',    'Lampu utama baru diganti LED Philips 14W.');

INSERT INTO `kostASIH_tr_hunian`
  (`id_hunian`, `id_user`, `id_kamar`, `tgl_mulai_sewa`, `tgl_selesai_sewa`, `status_sewa`)
VALUES
  (1, 10, 2,  '2026-01-05', '2027-01-05', 'sewa_aktif'),
  (2, 12, 4,  '2026-01-10', '2027-01-10', 'sewa_aktif'),
  (3, 13, 3,  '2026-03-10', '2027-03-10', 'terlambat_bayar'),
  (4, 14, 6,  '2025-08-15', '2026-12-15', 'sedang_mudik'),
  (5, 15, 5,  '2025-11-01', '2026-11-30', 'sewa_aktif'),
  (6, 16, 7,  '2026-02-01', '2027-02-01', 'terlambat_bayar'),
  (7, 17, 10, '2026-04-01', '2027-04-01', 'sewa_aktif');

INSERT INTO `kostASIH_md_pengaturan`
  (`id_pengaturan`, `nama_kos`, `nama_pemilik`, `email_pemilik`, `no_wa_pemilik`, `nama_bank`, `nomor_rekening`, `atas_nama_rekening`, `nmid_qris`, `denda_otomatis_aktif`, `tgl_jatuh_tempo_bulanan`, `tarif_denda_harian`, `batas_toleransi_hari`, `jadwal_notifikasi_fcm`)
VALUES
  (1, 'KosAsih Residence', 'Bu Asih', 'admin.buasih@kosasih.com', '+62 811-9234-8899', 'Bank BCA', '1234567890', 'PT KosAsih Sejahtera Utama', 'ID10260639281928', 1, 10, 20000, 1, 'Notifikasi Otomatis H-3 & H-1 via FCM');

INSERT INTO `kostASIH_tr_pembayaran`
  (`id_pembayaran`, `kode_invoice`, `id_kamar`, `id_user`, `periode_pembayaran`, `tenggat_pembayaran`, `nominal_pembayaran`, `biaya_tamu_pembayaran`, `denda_pembayaran`, `hari_terlambat`, `denda_dibebaskan`, `metode_pembayaran`, `bukti_pembayaran`, `kuitansi_pembayaran`, `status_pembayaran`, `tgl_unggah_bukti`, `tgl_lunas_pembayaran`, `diverifikasi_oleh`)
VALUES
  (101, '#INV-202610-A04', 4,  12, 'Oktober 2026', '2026-10-13', 1200000, 50000, 40000, 2, 0, 'Transfer Bank BCA',     'bukti_transfer_bca_a04.jpg',     NULL,                      'menunggu_verifikasi', '2026-10-15 08:45:00', NULL,                  NULL),
  (102, '#INV-202610-B01', 5,  15, 'Oktober 2026', '2026-10-15', 1200000, 0,     0,     0, 0, 'Transfer Bank Mandiri', 'bukti_transfer_mandiri_b01.jpg', NULL,                      'menunggu_verifikasi', '2026-10-15 09:10:00', NULL,                  NULL),
  (103, '#INV-202610-A02', 2,  10, 'Oktober 2026', '2026-10-15', 1200000, 0,     0,     0, 0, 'QRIS Instan',           'qris_oktober_a02.png',           'e_kuitansi_a02_okt2026.pdf', 'lunas',               '2026-10-12 14:15:00', '2026-10-12 14:20:00', 1),
  (104, '#INV-202610-B03', 6,  14, 'Oktober 2026', '2026-10-10', 1200000, 0,     0,     0, 0, 'Transfer Bank BCA',     'bukti_transfer_bca_b03.jpg',     'e_kuitansi_b03_okt2026.pdf', 'lunas',               '2026-10-09 10:05:00', '2026-10-09 10:30:00', 1),
  (105, '#INV-202610-A06', 3,  13, 'Oktober 2026', '2026-10-10', 1200000, 0,     60000, 3, 0, NULL,                    NULL,                             NULL,                      'terlambat',           NULL,                  NULL,                  NULL),
  (106, '#INV-202610-B04', 7,  16, 'Oktober 2026', '2026-10-10', 1200000, 0,     40000, 2, 0, NULL,                    NULL,                             NULL,                      'terlambat',           NULL,                  NULL,                  NULL);

INSERT INTO `kostASIH_tr_komplain`
  (`id_komplain`, `id_user`, `id_kamar`, `kategori_fasilitas`, `prioritas`, `judul_komplain`, `deskripsi_komplain`, `foto_komplain`, `catatan_komplain`, `status_komplain`, `tgl_komplain`, `tgl_selesai`)
VALUES
  (15, 12, 4,  'Pendingin Udara (AC)',  'Prioritas Tinggi', 'AC Tidak Dingin & Menetes',            'Sejak semalam AC hanya mengeluarkan angin biasa dan pipa indoor meneteskan air cukup deras ke lantai kamar.', 'bukti_ac_bocor_kamar_a04.jpg', 'Teknisi AC CV Sentosa Dingin dijadwalkan datang hari ini pukul 14.00 WIB.',                       'menunggu',          '2026-10-15 07:30:00', NULL),
  (14, 12, 4,  'Pendingin Udara (AC)',  'Prioritas Tinggi', 'AC kurang dingin & menetes',           'Pipa indoor meneteskan air ke lantai kamar.',                                                                'bukti_ac_bocor_kamar_a04.jpg', 'Teknisi AC langganan dijadwalkan tiba hari ini pukul 14.00 WIB. Mohon kunci kamar disiapkan.',    'sedang_diperbaiki', '2026-10-14 09:30:00', NULL),
  (9,  15, 8,  'Air & Sanitasi',        'Normal',           'Keran Wastafel Bocor & Patah Tuas',    'Tuas keran wastafel kamar mandi patah saat diputar.',                                                        'bukti_keran_b02.jpg',          'Seal keran diganti unit stainless baru, instalasi pipa diperkuat, dan debit air kini normal kembali.', 'selesai',           '2026-10-10 09:00:00', '2026-10-10 16:45:00'),
  (8,  17, 10, 'Kelistrikan & Lampu',   'Normal',           'Lampu Utama Kamar Redup & Berkedip',   'Lampu plafon utama kamar redup dan berkedip saat dinyalakan.',                                               NULL,                           'Penggantian fitting lampu plafon dan pemasangan LED Philips 14W baru bergaransi.',                 'selesai',           '2026-10-04 08:30:00', '2026-10-04 11:20:00');

INSERT INTO `kostASIH_tr_pengumuman`
  (`id_pengumuman`, `id_penulis`, `judul_pengumuman`, `isi_pengumuman`, `kategori_pengumuman`, `pin_pengumuman`, `tgl_pengumuman`)
VALUES
  (1, 1, 'Jadwal Pengurasan Tandon Air Kos',   'Jumat, 16 Okt 2026 pukul 09.00 - 11.30 WIB akan dilakukan pengurasan dan pembersihan tandon air utama. Aliran air dimatikan sementara. Mohon penghuni menampung air secukupnya.', 'Air & Tandon',    1, '2026-10-15 08:00:00'),
  (2, 1, 'Perubahan Password WiFi Oktober 2026', 'Password WiFi KosAsih lantai 1 & 2 telah diperbarui menjadi: KosAsihOktober26 demi keamanan dan kelancaran akses bersama.',                                                  'Jaringan WiFi',   0, '2026-10-01 07:30:00'),
  (3, 1, 'Himbauan Kunci Pagar Gerbang',        'Dimohon seluruh penghuni memastikan pagar gerbang terkunci kembali setelah keluar/masuk di atas pukul 22.00 WIB.',                                                            'Ketertiban Umum', 0, '2026-09-28 19:00:00'),
  (4, 1, 'Jadwal Laundry Pick-up',              'Taruh cucian kotor di keranjang depan kamar sebelum pukul 08.00.',                                                                                                          'Layanan Kos',     0, '2026-10-14 07:00:00');

INSERT INTO `kostASIH_tr_tamu_izin`
  (`id_tamu`, `id_user`, `id_kamar`, `jenis_laporan`, `nama_tamu`, `jumlah_tamu`, `lama_menginap_malam`, `biaya_tamu`, `tgl_mulai`, `tgl_selesai`, `keterangan`, `status_izin`)
VALUES
  (1, 12, 4, 'tamu_menginap', 'Rizky Ramadhan', 1, 1, 50000, '2026-10-12', '2026-10-13', 'Saudara menginap 1 malam (ditagihkan pada invoice Oktober 2026).', 'selesai'),
  (2, 14, 6, 'izin_mudik',    NULL,             0, 0, 0,     '2026-10-12', '2026-10-20', 'Izin mudik ke kampung halaman s.d. 20 Okt 2026.',                  'disetujui');

INSERT INTO `kostASIH_md_panduan`
  (`id_panduan`, `judul_panduan`, `kategori_panduan`, `isi_panduan`, `urutan`)
VALUES
  (1, 'Jam Malam & Keamanan Gerbang',       'Tata Tertib',       'Gerbang utama dikunci mulai pukul 22.00 WIB. Penghuni yang pulang lebih malam wajib mengunci kembali gembok gerbang.', 1),
  (2, 'Akses WiFi KosAsih Lantai 1 & 2',    'WiFi & Jaringan',   'SSID: KosAsih_Residence_5G | Password Oktober 2026: KosAsihOktober26. Dilarang mengunduh torrent/aktivitas ilegal.', 2),
  (3, 'Aturan Tamu Menginap',               'Tata Tertib',       'Tamu menginap wajib dilaporkan melalui menu Lapor Tamu / Izin sebelum pukul 21.00 WIB dengan tarif Rp 50.000/malam.', 3),
  (4, 'Jadwal Pengambilan Sampah & Laundry','Jadwal Kebersihan', 'Sampah rumah tangga diangkut setiap Senin, Rabu, Jumat pukul 07.30 WIB. Laundry pick-up setiap hari sebelum pukul 08.00 WIB.', 4);

INSERT INTO `kostASIH_tr_notifikasi`
  (`id_notifikasi`, `id_user_tujuan`, `judul`, `pesan`, `tipe`, `target_id`, `sudah_dibaca`)
VALUES
  (1, 1,  '2 Bukti Bayar Masuk',       'Kamar A-04 & B-01 mengunggah bukti transfer dan menunggu verifikasi.',                 'pembayaran',   101, 0),
  (2, 1,  '1 Komplain Fasilitas Baru', 'Kamar A-04 (Bagus Wihandono) melaporkan AC Tidak Dingin & Menetes.',                   'komplain',     15,  0),
  (3, 1,  '2 Kamar Terlambat Bayar',   'Kamar A-06 & B-04 melewati jatuh tempo Oktober 2026 dengan denda aktif.',               'denda',        105, 0),
  (4, 12, 'Jadwal Teknisi AC',         'Teknisi AC CV Sentosa Dingin dijadwalkan datang hari ini pukul 14.00 WIB.',            'komplain',     14,  0),
  (5, 12, 'Pengingat Tagihan Oktober', 'Tagihan sewa Oktober 2026 sebesar Rp 1.290.000 sedang menunggu verifikasi bendahara.',   'pembayaran',   101, 0);
