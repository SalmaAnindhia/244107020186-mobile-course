import 'package:flutter_test/flutter_test.dart';
import 'package:week_4_networking_rest_api/data/models/comment.dart';

void main() {
  test('Comment.fromJson aman terhadap field yang hilang', () {
    // Hanya id yang ada; sisanya hilang.
    final comment = Comment.fromJson({'id': 5});

    expect(comment.id, 5);
    expect(comment.postId, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });

  // Edge case tambahan buatanmu sendiri (diminta checklist):
  test('Comment.fromJson aman terhadap tipe yang salah', () {
    final comment = Comment.fromJson({'id': 'bukan-angka', 'name': 123});

    expect(comment.id, 0);
    expect(comment.name, '');
  });
}