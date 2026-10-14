import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/repositories/note_repository.dart';
import '../data/sync.dart';
import '../widgets/note_tile.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  void _refresh(WidgetRef ref) {
    ref.invalidate(notesProvider);
    ref.invalidate(dirtyCountProvider);
  }

  Future<void> _addNote(BuildContext context, WidgetRef ref) async {
    final titleC = TextEditingController();
    final bodyC = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Catatan baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleC,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: bodyC,
              decoration: const InputDecoration(labelText: 'Isi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (ok == true && titleC.text.trim().isNotEmpty) {
      await ref
          .read(noteRepositoryProvider)
          .addNote(title: titleC.text.trim(), body: bodyC.text.trim());
      _refresh(ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final dirty = ref.watch(dirtyCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Sinkronkan',
            onPressed: () async {
              final n = await syncNotes(ref.read(noteRepositoryProvider));
              _refresh(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$n catatan tersinkron')),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Badge(
              label: Text('${dirty.value ?? 0}'),
              child: const Icon(Icons.sync_problem),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNote(context, ref),
        child: const Icon(Icons.add),
      ),
      body: notes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat: $e'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => _refresh(ref),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (list) => list.isEmpty
            ? const Center(
                child: Text('Belum ada catatan. Tap + untuk menambah.'))
            : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final n = list[i];
                  return NoteTile(
                    note: n,
                    onTap: () => context.push('/note/${n.id}'),
                    onDelete: () async {
                      await ref
                          .read(noteRepositoryProvider)
                          .deleteNote(n.id!);
                      _refresh(ref);
                    },
                  );
                },
              ),
      ),
    );
  }
}