/// Model satu komentar dari GET /comments.
/// Semua field dibuat non-null; nilai default dipakai kalau JSON tidak lengkap.
class Comment {
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  /// fromJson aman null: `as num?` lalu `?? 0` mencegah crash
  /// "type 'Null' is not a subtype" kalau field hilang atau tipenya berubah.
  factory Comment.fromJson(Map<String, dynamic> json) {
  final postId = json['postId'];
  final id = json['id'];
  final name = json['name'];
  final email = json['email'];
  final body = json['body'];

  return Comment(
    postId: postId is num ? postId.toInt() : 0,
    id: id is num ? id.toInt() : 0,
    name: name is String ? name : '',
    email: email is String ? email : '',
    body: body is String ? body : '',
  );
}

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'id': id,
        'name': name,
        'email': email,
        'body': body,
      };
}