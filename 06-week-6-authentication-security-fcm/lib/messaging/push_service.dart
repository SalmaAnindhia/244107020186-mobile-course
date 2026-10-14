import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _local = FlutterLocalNotificationsPlugin();

String? pendingDeepLink;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

class PushService {
  PushService._();

  static Future<bool> requestNotificationPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  static Future<void> initLocalNotifications({
    void Function(String route)? onSelectNotification,
  }) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        // Klik banner foreground -> teruskan payload ke router.
        final route = response.payload;
        if (route != null && route.isNotEmpty) {
          pendingDeepLink = route;
          onSelectNotification?.call(route);
        }
      },
    );
  }

  /// Token lifecycle: ambil, kirim ke backend, pantau perubahan.
  static Future<void> initFcmToken({
    required Future<void> Function(String token) onToken,
  }) async {
    // 1. Ambil token saat ini dan kirim ke backend.
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await onToken(token);

    // 2. Token bisa berubah (reinstall, clear data, rotasi keamanan).
    FirebaseMessaging.instance.onTokenRefresh.listen(onToken);

    // 3. Langganan topik kampus.
    await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
  }

  static Future<void> unsubscribeTopic() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('pengumuman-kampus');
  }

  static void listenForeground(void Function(String route) go) {
    // Foreground: sistem tidak menampilkan banner otomatis,
    // jadi tampilkan manual via local notification.
    FirebaseMessaging.onMessage.listen((message) async {
      final route = message.data['route'] ?? '/';
      const androidDetails = AndroidNotificationDetails(
        'pengumuman',
        'Pengumuman Kampus',
        importance: Importance.high,
        priority: Priority.high,
      );
      await _local.show(
        id: message.hashCode,
        title: message.notification?.title ?? 'Pengumuman',
        body: message.notification?.body ?? '',
        notificationDetails: const NotificationDetails(android: androidDetails),
        payload: route,
      );
    });

    // Background -> diklik.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      go(message.data['route'] ?? '/');
    });
  }

  static Future<void> handleTerminated(void Function(String route) go) async {
    // Terminated -> dibuka dari notifikasi.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) go(initial.data['route'] ?? '/');
    if (pendingDeepLink != null) go(pendingDeepLink!);
  }
}