/// Entity domain: objek bisnis Pengumuman, murni Dart.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.body,
  });

  final String id;
  final String title;
  final String category;
  final String date;
  final String body;
}
