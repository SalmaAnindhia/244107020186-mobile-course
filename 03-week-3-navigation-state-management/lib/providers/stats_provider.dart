import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notifier async yang mensimulasikan pengambilan data statistik dari server.
class StatsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    return _fetchStats();
  }

  // Method buat manual refresh, dipanggil dari tombol "Coba lagi" atau refresh.
  Future<void> refresh() async {
    state = const AsyncLoading();               // set loading dulu
    state = await AsyncValue.guard(_fetchStats); // guard: exception -> AsyncError otomatis
  }

  Future<List<String>> _fetchStats() async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi network delay

    // Simulasi gagal 30% dari waktu (nextDouble() < 0.3 kira-kira 30% kemungkinan).
    if (Random().nextDouble() < 0.3) {
      throw Exception('Gagal mengambil data statistik');
    }

    return ['Pengguna aktif: 1.204', 'Total transaksi: 356', 'Rating rata-rata: 4.7'];
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<String>>(StatsNotifier.new);