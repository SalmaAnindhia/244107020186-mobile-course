import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_navigation/providers/stats_provider.dart'; 

void main() {
  test(
    'StatsNotifier menghasilkan 3 item atau error (simulasi gagal 30%)',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      try {
        final result = await container.read(statsProvider.future);
        expect(result.length, 3);
      } catch (e) {
        expect(e, isA<Exception>());
      }
    },
    timeout: const Timeout(Duration(seconds: 10)),
  );
}