import 'package:flutter/material.dart';

/// Halaman pembayaran QRIS.
class PembayaranQrisPage extends StatelessWidget {
  const PembayaranQrisPage({super.key});

  static const String routeName = '/pembayaran-qris';

  void _aksi(BuildContext context, String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Kamar A-04 • Bagus Wihandono',
              style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'QRIS',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      Text(
                        'GPN  •  NATIONAL STANDARD',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'PT KOSASIH SEJAHTERA UTAMA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'NMID : ID10260639281928',
                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '◷  Berlaku hingga 15:00',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC2410C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 210,
                    height: 210,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFF0F172A),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 13,
                              ),
                          itemCount: 169,
                          itemBuilder: (_, index) {
                            final int row = index ~/ 13;
                            final int col = index % 13;
                            final bool finder =
                                (row < 5 && col < 5) ||
                                (row < 5 && col > 7) ||
                                (row > 7 && col < 5);
                            final bool dark = finder
                                ? ((row == 0 ||
                                          row == 4 ||
                                          col == 0 ||
                                          col == 4) ||
                                      (row >= 1 &&
                                          row <= 3 &&
                                          col >= 1 &&
                                          col <= 3))
                                : (index * 17 + row * 3 + col) % 5 < 2;
                            return Container(
                              margin: const EdgeInsets.all(1),
                              color: dark ? Colors.black : Colors.white,
                            );
                          },
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D4ED8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.home,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'TOTAL TAGIHAN OTOMATIS',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Rp 1.290.000',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '✓  Nominal terisi otomatis saat discan',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _aksi(context, 'QR disiapkan untuk diunduh.'),
                          icon: const Icon(Icons.download, size: 15),
                          label: const Text(
                            'Unduh QR',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _aksi(context, 'QRIS siap dibagikan.'),
                          icon: const Icon(Icons.share, size: 15),
                          label: const Text(
                            'Bagikan QRIS',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: const [
                Text(
                  'Unggah Bukti Transaksi QRIS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text(
                  'Wajib diisi',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Setelah scan dan transfer melalui e-wallet atau m-banking, simpan lalu lampirkan screenshot bukti pembayaran.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _aksi(context, 'Pilih screenshot bukti QRIS.'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: Column(
                  children: const [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 27,
                      color: Color(0xFF1D4ED8),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Ketik untuk unggah screenshot QRIS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Format file JPG, PNG, atau PDF (Maks. 5MB)',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.description_outlined,
                    size: 16,
                    color: Color(0xFF1D4ED8),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'bukti_qris_sukses_27okt.jpg',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '380 KB  •  ✓ Terlampir',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.delete_outline,
                    size: 17,
                    color: Color(0xFFDC2626),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _aksi(
                  context,
                  'Bukti pembayaran QRIS terkirim, menunggu verifikasi bendahara.',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text(
                  'KIRIM BUKTI PEMBAYARAN',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                label: const Text(
                  'UNDUH E-KWITANSI PDF (LUNAS)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '* E-Kwitansi resmi baru tersedia sesaat setelah pembayaran terverifikasi bendahara.',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
