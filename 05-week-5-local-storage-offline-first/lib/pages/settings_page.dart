import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/prefs.dart';

final prefsRepositoryProvider = Provider((ref) => PrefsRepository());

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final lastOpenedProvider = FutureProvider<String?>((ref) async {
  final repo = ref.watch(prefsRepositoryProvider);
  final last = await repo.getLastOpened();
  await repo.markOpenedNow();
  return last;
});

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider);
    final last = ref.watch(lastOpenedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Mode gelap'),
            value: dark.value ?? false,
            onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          ListTile(
            title: const Text('Terakhir dibuka'),
            subtitle: Text(last.when(
              data: (v) => v ?? 'Belum pernah',
              loading: () => 'Memuat...',
              error: (e, _) => 'Gagal: $e',
            )),
          ),
        ],
      ),
    );
  }
}