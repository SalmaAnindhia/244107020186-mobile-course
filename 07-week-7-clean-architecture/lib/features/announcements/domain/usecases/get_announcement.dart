import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';

/// Use case: ambil detail pengumuman berdasarkan ID.
class GetAnnouncementUseCase {
  const GetAnnouncementUseCase(this._repository);
  final AnnouncementRepository _repository;

  Future<Announcement> call(String id) => _repository.getById(id);
}
