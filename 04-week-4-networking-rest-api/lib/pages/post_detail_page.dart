import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post.dart';
import '../data/network_errors.dart';
import '../data/providers.dart';

final postDetailProvider =
    FutureProvider.family<Post, int>((ref, id) {
  return ref.watch(postRepositoryProvider).fetchPostById(id);
});

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil dari list yang sudah dimuat kalau ada
    Post? cached;
    for (final p in ref.watch(postListProvider).value ?? const <Post>[]) {
      if (p.id == id) cached = p;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Post #$id')),
      body: cached != null
          ? _Content(post: cached)
          : ref.watch(postDetailProvider(id)).when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(friendlyErrorMessage(err),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () =>
                              ref.invalidate(postDetailProvider(id)),
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (post) => _Content(post: post),
              ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.title,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(post.body),
        ],
      ),
    );
  }
}