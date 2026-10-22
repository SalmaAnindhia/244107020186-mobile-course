import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';

/// Implementasi repository pengumuman dengan data statis (mock).
/// Pada produksi, ini akan memanggil Dio ke API.
class AnnouncementRepositoryImpl implements AnnouncementRepository {
  @override
  Future<Announcement> getById(String id) async {
    // Simulasi delay jaringan
    await Future.delayed(const Duration(milliseconds: 100));
    return _database[id] ??
        Announcement(
          id: id,
          title: 'Detail Pengumuman #$id',
          category: 'Umum',
          date: 'Hari ini',
          body:
              'Ini adalah konten rincian untuk pengumuman ID: $id. Notifikasi deep linking berhasil mengarahkan pengguna ke halaman rute spesifik.',
        );
  }

  static const _database = {
    '1': Announcement(
      id: '1',
      title: 'Batas Akhir Pengisian KRS Semester Ganjil',
      category: 'Akademik',
      date: '08 Oktober 2026',
      body:
          'Diberitahukan kepada seluruh mahasiswa JTI Polinema bahwa batas akhir pengisian dan persetujuan KRS oleh Dosen Pembina Akademik adalah Jumat, 10 Oktober 2026 pukul 23.59 WIB.',
    ),
    '2': Announcement(
      id: '2',
      title: 'Pendaftaran Webinar Cloud & Flutter Mobile',
      category: 'Kemahasiswaan',
      date: '07 Oktober 2026',
      body:
          'Ikuti webinar industri terkini seputar arsitektur cloud dan pengembangan mobile cross-platform bersama Google Developer Experts. Terbuka gratis dengan sertifikat.',
    ),
    '3': Announcement(
      id: '3',
      title: 'Perubahan Ruang Kuliah Pemrograman Mobile',
      category: 'Jadwal Kuliah',
      date: 'Hari ini, 12:45 WIB',
      body:
          'Pemberitahuan perubahan ruangan: Perkuliahan Pemrograman Mobile kelas TI-2B siang ini dipindahkan dari Gedung Sipil ke Lab JTI Gedung Presisi Lt. 6 Ruang A2 pukul 13.00 WIB.',
    ),
  };
}
