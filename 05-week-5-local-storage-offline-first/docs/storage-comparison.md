# AI Challenge: Perbandingan Local Storage (Offline Notes)

Aplikasi: **Offline Notes** (CRUD catatan + preferensi tema), Flutter + Riverpod.
Keputusan akhir: **SharedPreferences** untuk preferensi, **SQLite (sqflite)** untuk catatan.

---

## 1. Prompt yang digunakan

```
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
untuk dua kebutuhan ini. Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
  type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
  beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

Tool AI yang dipakai: Claude

---

## 2. Output awal AI (ringkasan)

### Perbandingan per kriteria

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
|---|---|---|---|---|
| Model data | Key-value primitif | Box NoSQL (key → objek) | Tabel relasional | Tabel relasional (di atas SQLite) |
| Kompleksitas query | Tidak ada, hanya get/set | Terbatas, filter manual di Dart | Penuh (SQL: WHERE, ORDER BY, JOIN, LIKE) | Penuh (SQL / Dart DSL) |
| Relasi | Tidak ada | Tidak native, referensi manual | Ya (foreign key, join) | Ya (foreign key, join, type-safe) |
| Reaktivitas (stream) | Tidak ada | Ada (`box.watch()`) | Tidak ada bawaan (pakai `ref.invalidate`) | Ada (`.watch()` → Stream) |
| Type-safety | Rendah | Sedang (TypeAdapter) | Rendah (Map + SQL string) | Tinggi (kode hasil generate) |
| Boilerplate | Sangat kecil | Sedang (adapter + codegen) | Sedang (mapping manual) | Terbesar (tabel + build_runner + migrasi) |
| Kemudahan testing | Mudah (`setMockInitialValues`) | Cukup | Cukup (repository palsu / FFI in-memory) | Baik (in-memory bawaan) |

### Trade-off

- **SharedPreferences**: cocok untuk pengaturan kecil. Tidak bisa query, update parsial, atau relasi. Menyimpan daftar catatan sebagai satu string JSON membuat setiap perubahan menulis ulang semua data, lambat dan rapuh untuk sinkronisasi.
- **Hive**: cepat, setup ringan, ada `watch()`. Tidak ada query/index sungguhan, jadi filter dan urutan dilakukan di memori. Perubahan skema harus dikelola lewat adapter.
- **sqflite**: SQL penuh, matang, dan stabil. Cocok untuk kolom `dirty` dan `updated_at`. Kekurangannya: SQL berupa string, mapping manual, dan tidak ada stream bawaan.
- **Drift**: type-safe, stream reaktif, migrasi terstruktur. Boilerplate dan build time terbesar, kurva belajar paling curam. Bisa berlebihan untuk aplikasi catatan kecil.

---

## 3. Keputusan final

| Kebutuhan | Pilihan | Alasan | Alternatif |
|---|---|---|---|
| Preferensi (tema, last opened) | **SharedPreferences** | Data kecil dan primitif, tidak perlu query/relasi, setup paling ringan | - |
| Catatan (CRUD + sync) | **sqflite (SQLite)** | Butuh urut `updated_at`, filter `dirty`, dan skala 1000+ baris dengan index. Boilerplate masih wajar untuk skala ini | Drift, jika butuh UI auto-update lewat stream atau query makin kompleks |

**Alasan Hive tidak dipilih:** tidak ada query/index untuk memfilter `dirty`, sinkronisasi dua arah lebih sulit tanpa SQL, dan paket aslinya sudah lama tidak dirilis (lihat bagian 6).

**Alasan Drift tidak dipilih (untuk sekarang):** boilerplate (`build_runner`, definisi tabel) tidak sebanding dengan kebutuhan aplikasi ini. Kebutuhan refresh UI sudah tercukupi dengan `ref.invalidate` setelah setiap mutasi.

---

## 4. Skema untuk 1000+ catatan

### sqflite (dipakai)

```sql
CREATE TABLE notes(
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  title       TEXT    NOT NULL,
  body        TEXT    NOT NULL DEFAULT '',
  updated_at  TEXT    NOT NULL,            -- ISO-8601, dasar last-write-wins
  dirty       INTEGER NOT NULL DEFAULT 0   -- 1 = belum tersinkron
);

CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);
CREATE INDEX idx_notes_dirty      ON notes(dirty) WHERE dirty = 1;

CREATE TABLE cached_posts(
  id        INTEGER PRIMARY KEY,
  payload   TEXT NOT NULL,
  cached_at TEXT NOT NULL
);
```

Query utama:

```sql
-- Daftar catatan (dengan pagination)
SELECT * FROM notes ORDER BY updated_at DESC LIMIT 50 OFFSET 0;

-- Antrean sinkronisasi
SELECT * FROM notes WHERE dirty = 1;
```

### SharedPreferences

| Key | Tipe | Fungsi |
|---|---|---|
| `dark_mode` | bool | Tema gelap/terang |
| `last_opened_at` | String (ISO-8601) | Waktu terakhir aplikasi dibuka |

### Hive (alternatif, tidak dipakai)

- Box `notes`: key = `id` (int), value = objek `NoteModel` lewat `TypeAdapter`.
- Box `settings`: key `dark_mode`, `last_opened_at`.
- Filter `dirty` dilakukan manual: `box.values.where((n) => n.dirty)`.

---

## 5. Aturan konflik sinkronisasi

**Last-write-wins** berdasarkan `updated_at`: jika catatan yang sama berbeda antara lokal dan server, versi dengan `updated_at` terbaru yang dipakai. Catatan lokal yang belum terkirim ditandai `dirty = 1` sampai server menjawab sukses, lalu `dirty = 0`.

Pada project ini server hanya disimulasikan (`Future.delayed` 1 detik di `syncNotes`), jadi yang diuji adalah mekanisme dirty flag dan antreannya, bukan penyelesaian konflik dua arah.

---

## 6. Verifikasi (AI Verification Checklist)

| Pertanyaan | Temuan AI | Temuan saya |
|---|---|---|
| Apakah AI menaruh daftar catatan di SharedPreferences? | Tidak. SharedPreferences hanya direkomendasikan untuk preferensi. | Saya setuju. Di aplikasi saya, SharedPreferences hanya menyimpan `dark_mode` dan `last_opened_at`. Daftar catatan ada di tabel `notes`, karena kalau disimpan sebagai satu string JSON, tambah satu catatan berarti menulis ulang semuanya dan tidak bisa difilter berdasarkan `dirty`. |
| Apakah skema mendukung antrean sync (dirty flag / updated_at)? | Ya, kolom `dirty` dan `updated_at` ada. | Terbukti saat saya jalankan: setiap catatan baru tersimpan dengan `dirty = 1` (ikon awan oranye dan badge naik). Setelah tombol sync ditekan, `markAllSynced()` mengubahnya jadi `dirty = 0`, ikon berubah hijau dan badge kembali 0. |
| Apakah klaim "reaktif" didukung stream? | Hanya Drift dan Hive yang punya stream. sqflite memakai `ref.invalidate`. | Benar. Di sqflite tidak ada stream, jadi saya memanggil `ref.invalidate(notesProvider)` dan `ref.invalidate(dirtyCountProvider)` setelah tambah, hapus, dan sync (fungsi `_refresh` di `notes_page.dart`). Kalau lupa, UI tidak berubah. Ini kelemahan nyata dibanding Drift `.watch()`. |
| Apakah estimasi boilerplate masuk akal? | Hive butuh adapter, Drift butuh build_runner, sqflite paling ringan. | Sebagian saya buktikan sendiri. Untuk sqflite saya menulis `Note.toMap/fromMap`, `db.dart`, dan repository secara manual, jumlahnya masih wajar. Untuk Hive dan Drift, saya baru membandingkan dari contoh kode (adapter manual di Hive, `part '*.g.dart'` + `build_runner` di Drift), belum memasangnya di project ini. |
| Status paket (aktif dirawat?) | Perlu dicek di pub.dev. | Lihat tabel di bawah. Temuan penting: paket `hive` asli terakhir dirilis tahun 2022. |
| Hambatan nyata saat implementasi | Tidak disebut AI. | `sqflite` biasa tidak jalan di Windows/Chrome (`databaseFactory not initialized`). Solusinya menjalankan di Android, atau di desktop memakai `sqflite_common_ffi`. Ini keterbatasan yang tidak ada di SharedPreferences. |

### Status paket (dicek di pub.dev)

| Paket | Versi terbaru | Rilis terakhir | Catatan |
|---|---|---|---|
| `hive` (asli) | 2.2.3 | 30 Juni 2022 | Stabil terakhir 2.2.3. Versi 4.0.0 hanya prerelease (`4.0.0-dev.2`, sekitar 2 tahun lalu). Tidak ada rilis stabil baru selama sekitar 4 tahun. |
| `hive_ce` (fork komunitas) | 2.19.3 | Februari 2026 | "Spiritual continuation" Hive v2, jadi pengganti yang masih aktif. |
| `drift` | 2.35.1 | 30 September 2026 | Sangat aktif, rilis beberapa kali per bulan dalam 4 bulan terakhir. |

Kesimpulan: **Drift aktif dirawat**, sedangkan **Hive asli praktis tidak dirawat lagi** (kalau mau Hive, lebih aman pakai `hive_ce`). Ini memperkuat keputusan saya untuk tidak memakai Hive asli.

### Bagian rekomendasi AI yang saya terima / tolak

- **Diterima:** SharedPreferences untuk preferensi dan sqflite untuk catatan. Alasannya kebutuhan sync (`dirty`, `updated_at`) cocok dengan SQL, dan skala 1000+ catatan aman dengan index.
- **Diterima dengan catatan:** saran index `idx_notes_updated_at` dan `idx_notes_dirty`. Ini berguna di 1000+ baris, tetapi tidak wajib untuk demo.
- **Ditolak / dikoreksi:** klaim AI bahwa Hive "kurang aktif dirawat" awalnya saya anggap belum pasti, jadi saya cek sendiri di pub.dev. Hasilnya benar untuk paket `hive` asli (rilis terakhir 2022), tetapi ada fork `hive_ce` yang masih aktif. Jadi alasan menolak Hive saya perkuat: bukan hanya soal paket, tetapi karena tidak ada query/index untuk memfilter `dirty`.
- **Tidak saya ambil:** Drift. Fiturnya bagus (stream, type-safe), tetapi untuk aplikasi catatan sekecil ini boilerplate-nya tidak sebanding.

---

## 7. Bukti pengujian

- [ ] Screenshot daftar catatan saat mode pesawat (folder `screenshots/`)
- [ ] Screenshot badge dirty sebelum sync
- [ ] Screenshot badge dirty sesudah sync (0)
- [ ] `flutter analyze` tanpa issue
- [ ] `flutter test` semua lulus

---

## 8. Bahan penjelasan saat demo

**Q: Kenapa SharedPreferences + SQLite?**
Karena aplikasi ini punya dua jenis data yang sifatnya berbeda. Preferensi (tema, waktu terakhir dibuka) kecil, primitif, dan hanya dibaca/ditulis per key, jadi SharedPreferences paling sederhana. Catatan adalah koleksi yang perlu diurutkan berdasarkan `updated_at`, difilter berdasarkan `dirty` untuk antrean sync, dan bisa membesar sampai 1000+ baris. Itu pekerjaan database relasional dengan index, bukan key-value.

**Q: Kenapa daftar catatan tidak boleh di SharedPreferences?**
Semua catatan harus disimpan sebagai satu string JSON. Setiap perubahan kecil menulis ulang seluruh data, tidak ada query atau update parsial, dan sulit menandai catatan mana yang belum tersinkron. Makin banyak catatan, makin lambat dan rapuh.

**Q: Kenapa bukan Drift?**
Drift bagus karena type-safe dan punya stream, tetapi butuh `build_runner`, definisi tabel, dan migrasi terstruktur. Untuk aplikasi catatan kecil, boilerplate itu tidak sebanding. Kekurangan sqflite (tidak ada stream) saya atasi dengan `ref.invalidate`. Kalau aplikasi membesar dan query makin kompleks, Drift adalah langkah berikutnya.

**Q: Kenapa bukan Hive?**
Hive tidak punya query/index, jadi filter `dirty` dan pengurutan dilakukan manual di memori. Paket `hive` aslinya juga terakhir dirilis Juni 2022. Kalau tetap mau Hive, pilihan yang aktif adalah fork `hive_ce`.

**Q: Bagaimana offline-first bekerja di aplikasi ini?**
Catatan selalu ditulis ke SQLite lebih dulu dengan `dirty = 1`, jadi tetap jalan tanpa internet. Saat sync, `syncNotes` mengirim (disimulasikan) lalu `markAllSynced()` mengubah `dirty` jadi 0. Untuk data API (posts), alurnya cache-first: tampilkan cache lokal, lalu refresh di background dan simpan hasilnya.

**Q: Bagaimana kalau terjadi konflik?**
Aturannya last-write-wins berdasarkan `updated_at`. Server di project ini hanya simulasi, jadi yang saya buktikan adalah mekanisme dirty flag dan antreannya.
