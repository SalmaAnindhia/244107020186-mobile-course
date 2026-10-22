import 'package:flutter_test/flutter_test.dart';
import 'package:week_7_clean_architecture/features/announcements/domain/entities/announcement.dart';
import 'package:week_7_clean_architecture/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:week_7_clean_architecture/features/announcements/domain/usecases/get_announcement.dart';

class FakeAnnouncementRepository implements AnnouncementRepository {
  @override
  Future<Announcement> getById(String id) async {
    return Announcement(
      id: id,
      title: 'Pengumuman Test $id',
      category: 'Test',
      date: 'Hari ini',
      body: 'Ini pengumuman untuk test id $id',
    );
  }
}

void main() {
  late GetAnnouncementUseCase useCase;

  setUp(() {
    useCase = GetAnnouncementUseCase(FakeAnnouncementRepository());
  });

  group('GetAnnouncementUseCase', () {
    test('mengembalikan Announcement dengan id yang benar', () async {
      final announcement = await useCase('42');
      expect(announcement.id, '42');
      expect(announcement.title, contains('42'));
      expect(announcement.body, isNotEmpty);
    });
  });
}
