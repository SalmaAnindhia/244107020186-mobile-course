/// Definisi konstanta rute terpusat untuk aplikasi Campus Notification.
/// Menjaga konsistensi rute antara GoRouter dan FCM deep link data payload.
class Routes {
  Routes._();

  static const String home = '/';
  static const String login = '/login';
  static const String announcement = '/pengumuman/:id';

  /// Helper untuk membangun rute pengumuman berdasarkan ID
  static String announcementPath(String id) => '/pengumuman/$id';
}
