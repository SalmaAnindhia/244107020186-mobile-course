import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcement.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>(
  (_) => AnnouncementRepositoryImpl(),
);

final getAnnouncementUseCaseProvider = Provider<GetAnnouncementUseCase>(
  (ref) => GetAnnouncementUseCase(ref.watch(announcementRepositoryProvider)),
);

final announcementProvider =
    FutureProvider.family<Announcement, String>((ref, id) {
  return ref.watch(getAnnouncementUseCaseProvider)(id);
});
