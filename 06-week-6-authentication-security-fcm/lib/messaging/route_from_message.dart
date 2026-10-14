import '../routes.dart';

/// Fungsi murni: mengubah data payload FCM menjadi rute tujuan.
/// Tidak bergantung pada Firebase sehingga mudah diunit-test.
String routeFromMessage(Map<String, dynamic> data) {
  final route = (data['route'] as String?)?.trim();
  if (route == null || route.isEmpty) return Routes.home;
  return route.startsWith('/') ? route : '/$route';
}
