import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/note_repository.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteByIdProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('Detail catatan')),
      body: noteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (note) {
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.title,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Diubah: ${note.updatedAt}'),
                if (note.dirty) const Text('Status: belum tersinkron'),
                const Divider(height: 24),
                Text(note.body.isEmpty ? '(kosong)' : note.body),
              ],
            ),
          );
        },
      ),
    );
  }
}