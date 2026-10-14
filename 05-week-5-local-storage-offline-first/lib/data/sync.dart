import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'local/db.dart';
import 'repositories/note_repository.dart';

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

class Post {
  const Post({required this.id, required this.title, required this.body});
  final int id;
  final String title;
  final String body;

  Map<String, Object?> toJson() => {'id': id, 'title': title, 'body': body};

  factory Post.fromJson(Map<String, Object?> json) => Post(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );
}

Future<List<Post>> readCachedPosts() async {
  final db = await openNotesDb();
  final rows = await db.query('cached_posts', orderBy: 'id ASC');
  return rows
      .map((r) => Post.fromJson(
          jsonDecode(r['payload'] as String) as Map<String, Object?>))
      .toList();
}

Future<void> saveCachedPosts(List<Post> posts) async {
  final db = await openNotesDb();
  final batch = db.batch();
  batch.delete('cached_posts');
  for (final p in posts) {
    batch.insert(
      'cached_posts',
      {
        'id': p.id,
        'payload': jsonEncode(p.toJson()),
        'cached_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  await batch.commit(noResult: true);
}

Future<List<Post>> fetchRemotePosts() async {
  final res = await Dio().get<List<dynamic>>(
    'https://jsonplaceholder.typicode.com/posts',
    options: Options(receiveTimeout: const Duration(seconds: 8)),
  );
  return (res.data ?? [])
      .take(20)
      .map((e) => Post.fromJson(Map<String, Object?>.from(e as Map)))
      .toList();
}

class PostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final cached = await readCachedPosts();
    if (cached.isEmpty) {
      return await _refresh() ?? cached;
    }
    _refresh();
    return cached;
  }

  Future<List<Post>?> _refresh() async {
    if (ref.read(forceOfflineProvider)) return null;
    try {
      final fresh = await fetchRemotePosts();
      await saveCachedPosts(fresh);
      state = AsyncData(fresh);
      return fresh;
    } catch (_) {
      return null; // offline/gagal: tetap pakai cache
    }
  }

  Future<void> refresh() => _refresh();
}

final postsProvider =
    AsyncNotifierProvider<PostsNotifier, List<Post>>(PostsNotifier.new);


Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}