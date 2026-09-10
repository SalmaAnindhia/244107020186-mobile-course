# Minggu 2 Declarative UI Responsive Design

## Deskripsi
Aplikasi Flutter dashboard mahasiswa yang menampilkan header profil dan kartu-kartu informasi akademik, dengan layout responsif serta dukungan light/dark theme dan aksesibilitas dasar.

## Fitur
- Header profil (nama, NIM, kelas) menggunakan `Container`, `Row`, `Column`.
- Minimal 4 kartu informasi (`InfoCard`): Assignments, Attendance, Portfolio, Current week.
- Layout responsif via `LayoutBuilder` — 1 kolom di bawah `900px`, 2 kolom di atasnya.
- Toggle tema light/dark manual menggunakan `CupertinoSwitch` (komponen Cupertino di dalam `AppBar` Material).
- Label aksesibilitas (`Semantics`) pada kartu info dan tombol toggle tema.

## Struktur Widget
- `DashboardApp` (StatefulWidget) — menyimpan state tema (`isDark`).
- `DashboardPage` — menyusun `AppBar`, `ProfileHeader`, dan grid `InfoCard`.
- `ProfileHeader` — menampilkan identitas mahasiswa.
- `InfoCard` — widget reusable untuk kartu informasi (title + value).

## AI Prompt Challenge

### Prompt 1 — Desain
**Prompt:** "Bandingkan dua tata letak dashboard akademik untuk Flutter: versi `GridView` dan versi `LayoutBuilder` + `Column`. Jelaskan trade-off responsif dan aksesibilitasnya."

**Output penting:** GridView cocok untuk kartu seragam, ringkas, otomatis wrapping, tapi ukuran item dipaksa sama. LayoutBuilder+Column lebih fleksibel untuk layout asimetris tapi lebih verbose. GridView lebih mudah diakses screen reader karena urutan linear otomatis.

**Keputusan yang dipilih:** Tetap menggunakan `GridView` karna kartu info dashboard berstruktur seragam.

**Alasan teknis:** Jumlah dan bentuk kartu info tetap (title + value), tidak butuh layout asimetris, sehingga `GridView` lebih sederhana dan cukup untuk kebutuhan ini.

### Prompt 2 — Penguatan Konsep
**Prompt:** "Jelaskan kapan penggunaan `Expanded` justru menyebabkan overflow di dalam `Row`, beri contoh kode yang gagal dan perbaikannya."

**Output penting:** Overflow terjadi jika `Expanded` dipakai di luar Row/Column, atau teks panjang di dalam Row tidak dibungkus `Expanded`. Solusi: bungkus dengan `Expanded` + `overflow: TextOverflow.ellipsis`.

**Keputusan:** Diterapkan sebagai catatan best practice; tidak ada perubahan kode karena teks pada `InfoCard` sudah pendek dan aman dari overflow.

### Prompt 3 — Verification
**Prompt:** "Periksa kembali rekomendasi layout di atas: apakah tetap responsif di bawah 600px, apakah mengurangi aksesibilitas, dan apakah ada widget yang tidak tersedia di Flutter stabil saat ini?"

**Output penting:** Layout tetap responsif di bawah 600px, tidak mengurangi aksesibilitas (ellipsis tidak memotong teks yang dibaca screen reader), dan semua widget yang direkomendasikan tersedia di Flutter stable.

**Verifikasi yang dilakukan:** Diuji manual dengan resize emulator ke ukuran ponsel dan tablet, serta memastikan `Semantics` tetap terbaca (dicek lewat `showSemanticsDebugger: true`).

## Refactoring
1. `DashboardCard` diekstrak/direname menjadi `InfoCard` (reusable, menerima `title` dan `value`).
2. Warna hardcode di `ProfileHeader` diganti menggunakan `Theme.of(context).colorScheme.*` agar otomatis menyesuaikan tema.
3. Breakpoint dipindahkan ke konstanta tunggal `const kWideBreakpoint = 900.0;`.
4. `flutter analyze` dijalankan, hasil: **[isi hasilnya di sini, misal "No issues found!"]**

## Testing
Widget test disimpan di `test/` untuk memverifikasi:
- Dashboard menampilkan 1 kolom pada layar sempit (`<700px` lebar).
- Dashboard menampilkan 2 kolom pada layar lebar (`>700px` lebar).

Dijalankan dengan `flutter test`, hasil: **[isi hasilnya di sini]**

## Screenshot
- `screenshots/responsive dashboard 2 terang.jpg` — tampilan layar terang.
- `screenshots/responsive dashboard 2 gelap.jpg` — tampilan layar gelap.
- `screenshots/tugas layar sempit.jpg` — tampilan layar sempit (1 kolom).
- `screenshots/tugas kalau layar lebar.jpg` — tampilan layar lebar (2 kolom).
- `screenshots/eksperimen layout.jpg` — eksperimen layout.
- `screenshots/tugas utama.jpg` — tugas utama.
## Checklist Verifikasi
- [x] `flutter analyze` tidak menghasilkan error
- [x] `flutter test` lulus semua widget test responsif
- [x] Aplikasi berjalan di ukuran layar sempit dan lebar
- [x] Dark mode memiliki kontras dan teks yang terbaca
- [x] Screenshot, folder `test/`, dan README sudah tersimpan
## Bukti
- `screenshots/flutter analyze.jpg` — Bukti keberhasilan flutter test.
- `screenshots/flutter test.jpg` — Bukti keberhasilan flutter test.

## Refleksi
- **Perbedaan imperative vs declarative:** Imperative itu mengubah UI manual step-by-step, sdgkn declarative mendeskripsikan tampilan berdasarkan state, Flutter yang mengurus rebuild-nya secara otomatis.
- **Kapan `Expanded` membantu vs menyebabkan error:** Expanded membantu kalau dipakai di dalam Row/Column buat ngisi sisa ruang menghindari overflow. Error itu kalau dipakai di luar Row/Column, atau salah alokasi ruang antar expanded.
- **Pengaruh breakpoint dan theme terhadap UX:** Breakpoint bikin layout nyaman di berbagai ukuran layar HP mau tablet, sdgkn untuk theme (light/dark) menjaga kontras & kenyamanan visual sesuai kondisi/preferensi user.
- **Apa yang diverifikasi dari rekomendasi AI:** Mengecek manual: tetap responsif di layar sempit, label aksesibilitas (Semantics) tetap kebaca, dan widget yang disaranin masih valid di Flutter stable.