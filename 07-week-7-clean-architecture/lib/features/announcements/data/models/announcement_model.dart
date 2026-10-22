import '../../domain/entities/announcement.dart';

/// Model: mapping data ke entity Announcement.
class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.category,
    required super.date,
    required super.body,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      AnnouncementModel(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        date: json['date'] as String,
        body: json['body'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'date': date,
        'body': body,
      };
}
