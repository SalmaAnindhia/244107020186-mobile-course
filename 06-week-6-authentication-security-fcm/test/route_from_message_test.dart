import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/data/api_errors.dart';
import '../lib/messaging/route_from_message.dart';

void main() {
  group('routeFromMessage', () {
    test('route kosong -> home', () {
      expect(routeFromMessage({}), '/');
    });

    test('route tanpa slash diberi slash', () {
      expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    });

    test('route normal tidak berubah', () {
      expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
    });

    test('route berisi spasi saja -> home', () {
      expect(routeFromMessage({'route': '   '}), '/');
    });
  });

  group('friendlyMessage', () {
    test('401 -> sesi berakhir', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 401,
        ),
      );
      expect(friendlyMessage(e), 'Sesi berakhir. Silakan login ulang.');
    });

    test('connectionError -> tidak ada koneksi', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      );
      expect(friendlyMessage(e), 'Tidak ada koneksi internet.');
    });

    test('error non-Dio -> pesan umum', () {
      expect(friendlyMessage(Exception('x')), 'Terjadi kesalahan. Coba lagi.');
    });
  });
}
