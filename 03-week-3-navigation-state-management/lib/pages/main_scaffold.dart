import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = location == '/stats' ? 1 : 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          context.go(index == 0 ? '/' : '/stats');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist), label: 'ToDo'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Statistik'),
        ],
      ),
    );
  }
}