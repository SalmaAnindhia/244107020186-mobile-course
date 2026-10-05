# 01 - Prompt yang Digunakan

Prompt dikirim ke AI assistant (Claude) sesuai instruksi AI Prompt Challenge Minggu 4:

```
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error
  ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

Konteks tambahan: project memakai Riverpod 3.x (`flutter_riverpod ^3.4.3`), Dio terpusat di `createDio()`, dan nama package `week_4_networking_rest_api`.
