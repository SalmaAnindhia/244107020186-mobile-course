import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes.dart';

class AnnouncementPage extends StatelessWidget {
  final String id;

  const AnnouncementPage({super.key, required this.id});

  Map<String, String> _getAnnouncementData(String id) {
    switch (id) {
      case '1':
        return {
          'title': 'Batas Akhir Pengisian KRS Semester Ganjil',
          'category': 'Akademik',
          'date': '08 Oktober 2026',
          'body':
              'Diberitahukan kepada seluruh mahasiswa JTI Polinema bahwa batas akhir pengisian dan persetujuan KRS oleh Dosen Pembina Akademik adalah Jumat, 10 Oktober 2026 pukul 23.59 WIB.',
        };
      case '2':
        return {
          'title': 'Pendaftaran Webinar Cloud & Flutter Mobile',
          'category': 'Kemahasiswaan',
          'date': '07 Oktober 2026',
          'body':
              'Ikuti webinar industri terkini seputar arsitektur cloud dan pengembangan mobile cross-platform bersama Google Developer Experts. Terbuka gratis dengan sertifikat.',
        };
      case '3':
        return {
          'title': 'Perubahan Ruang Kuliah Pemrograman Mobile',
          'category': 'Jadwal Kuliah',
          'date': 'Hari ini, 12:45 WIB',
          'body':
              'Pemberitahuan perubahan ruangan: Perkuliahan Pemrograman Mobile kelas TI-2B siang ini dipindahkan dari Gedung Sipil ke Lab JTI Gedung Presisi Lt. 6 Ruang A2 pukul 13.00 WIB.',
        };
      default:
        return {
          'title': 'Detail Pengumuman #$id',
          'category': 'Umum',
          'date': 'Hari ini',
          'body':
              'Ini adalah konten rincian untuk pengumuman ID: $id. Notifikasi deep linking berhasil mengarahkan pengguna ke halaman rute spesifik.',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _getAnnouncementData(id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengumuman'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.home);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                data['category']!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              data['title']!,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  data['date']!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  'ID: $id',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              data['body']!,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Card(
              color: Colors.green.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.green.shade200),
              ),
              child: const Padding(
                padding: EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Deep link FCM berhasil ditangani oleh GoRouter menuju rute /pengumuman/:id.',
                        style: TextStyle(fontSize: 13, color: Colors.green),
                      ),
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
