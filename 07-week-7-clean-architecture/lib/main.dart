import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'messaging/push_service.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/announcements/presentation/pages/announcement_page.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initializeApp skipped/fallback: $e');
  }

  try {
    registerBackgroundHandler();
  } catch (e) {
    debugPrint('registerBackgroundHandler fallback: $e');
  }

  final container = ProviderContainer();

  await container.read(authStateProvider.future);

  final authListenable = ValueNotifier<int>(0);
  container.listen(authStateProvider, (_, _) => authListenable.value++);

  final router = GoRouter(
    initialLocation: Routes.home,
    refreshListenable: authListenable,
    redirect: (context, state) {
      final loggedIn = container.read(authStateProvider).value ?? false;
      final goingLogin = state.matchedLocation == Routes.login;

      if (!loggedIn && !goingLogin) return Routes.login;
      if (loggedIn && goingLogin) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: Routes.announcement,
        builder: (context, state) => AnnouncementPage(
          id: state.pathParameters['id'] ?? '1',
        ),
      ),
    ],
  );

  try {
    await PushService.initLocalNotifications(
      onSelectNotification: (route) => router.go(route),
    );
    await PushService.requestNotificationPermission();
    PushService.listenForeground((route) => router.go(route));
    await PushService.handleTerminated((route) => router.go(route));
  } catch (e) {
    debugPrint('Push setup fallback: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: CampusNotifyApp(router: router),
    ),
  );
}

class CampusNotifyApp extends StatelessWidget {
  final GoRouter router;

  const CampusNotifyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Notification App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
