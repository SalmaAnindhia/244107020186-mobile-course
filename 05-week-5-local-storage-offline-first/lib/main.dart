import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'pages/note_detail_page.dart';
import 'pages/notes_page.dart';
import 'pages/posts_page.dart';
import 'pages/settings_page.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeShell()),
    GoRoute(
      path: '/note/:id',
      builder: (context, state) =>
          NoteDetailPage(id: int.parse(state.pathParameters['id']!)),
    ),
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider).value ?? false;
    return MaterialApp.router(
      routerConfig: _router,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: dark ? Brightness.dark : Brightness.light,
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _pages = const [NotesPage(), PostsPage(), SettingsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.note), label: 'Catatan'),
          NavigationDestination(icon: Icon(Icons.cloud), label: 'Posts'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
    );
  }
}