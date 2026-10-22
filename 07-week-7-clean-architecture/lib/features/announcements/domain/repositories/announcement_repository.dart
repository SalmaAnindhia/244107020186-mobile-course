import '../entities/announcement.dart';

/// Kontrak repository pengumuman — tinggal di domain layer.
abstract interface class AnnouncementRepository {
  Future<Announcement> getById(String id);
}
