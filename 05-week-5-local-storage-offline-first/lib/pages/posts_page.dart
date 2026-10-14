import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sync.dart';

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);
    final offline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts (cache-first)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(postsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Simulasi offline'),
            value: offline,
            onChanged: (v) => ref.read(forceOfflineProvider.notifier).set(v),
          ),
          Expanded(
            child: posts.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal: $e')),
              data: (list) => list.isEmpty
                  ? const Center(
                      child: Text('Cache kosong. Online dulu untuk mengisi cache.'))
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) => ListTile(
                        title: Text(list[i].title),
                        subtitle: Text(
                          list[i].body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}