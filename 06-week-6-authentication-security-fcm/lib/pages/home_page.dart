import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _token = '(belum ada)';
  final List<String> _log = [];

  // Tampilkan 12 karakter pertama saja, jangan pernah token penuh.
  String _mask(String t) => t.length > 12 ? '${t.substring(0, 12)}...' : t;

  @override
  void initState() {
    super.initState();
    _initToken();
  }

  Future<void> _initToken() async {
    try {
      await PushService.initFcmToken(onToken: (token) async {
        if (!mounted) return;
        setState(() {
          _token = _mask(token);
          _log.add(
            '${TimeOfDay.now().format(context)} token dikirim ke '
            'POST /devices: ${_mask(token)}',
          );
        });
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _log.add('Gagal ambil token: $e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notification App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DEBUG',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('FCM token: $_token'),
            const SizedBox(height: 8),
            const Text('Log:'),
            ..._log.map(Text.new),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(Routes.announcementPath('3')),
              child: const Text('Buka Pengumuman #3'),
            ),
          ],
        ),
      ),
    );
  }
}