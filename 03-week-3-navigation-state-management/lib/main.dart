import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'pages/detail_page.dart';
import 'pages/home_page.dart';
import 'pages/todo_page.dart';
import 'pages/product_page.dart';
import 'pages/stats_page.dart';
import 'pages/main_scaffold.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // ShellRoute: '/' dan '/stats' dibungkus NavigationBar persisten
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const TodoPage(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatsPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'detail/:id',
          builder: (context, state) => DetailPage(
            id: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductPage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Week 3 - Navigation',
      routerConfig: _router,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    );
  }
}