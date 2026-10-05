# 04 - Hasil Testing

Perintah dijalankan dari folder `04-week-4-networking-rest-api`.

## Sebelum perbaikan (percobaan pertama)

```
PS D:\244107020186-mobile-course\04-week-4-networking-rest-api> flutter analyze
>> flutter test
Analyzing 04-week-4-networking-rest-api...

warning - Unused import: 'pages/post_list_page.dart'. Try removing the import directive - lib\main.dart:3:8 - unused_import

1 issue found. (ran in 63.9s)
00:17 +1 -1: D:/244107020186-mobile-course/04-week-4-networking-rest-api/test/comment_test.dart: Comment.fromJson aman terhadap tipe yang salah [E]
  type 'String' is not a subtype of type 'num?' in type cast
  package:week_4_networking_rest_api/data/models/comment.dart 23:23  new Comment.fromJson
  test\comment_test.dart 18:29                                       main.<fn>

00:21 +5 -1: Some tests failed.
```

**Temuan:**

1. Warning `unused_import` di `main.dart`: `home` sudah memakai `PagedPostPage`, sehingga import `post_list_page.dart` tidak terpakai.
2. Test `tipe yang salah` gagal karena cast langsung di `Comment.fromJson`. Ini bug nyata di kode hasil AI (lihat dokumen 03, perbaikan 1).

## Sesudah perbaikan

```
$ flutter analyze
<tempel output setelah perbaikan; target: No issues found!>

$ flutter test
<tempel output setelah perbaikan; target: All tests passed!>
```

## Ringkasan

| Pemeriksaan | Sebelum | Sesudah |
| --- | --- | --- |
| `flutter analyze` | 1 warning (`unused_import`) | `<isi>` |
| `flutter test` | 5 lulus, 1 gagal | `<isi>` |
