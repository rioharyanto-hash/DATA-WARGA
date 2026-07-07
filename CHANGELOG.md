## [2026-07-07]
### [PATCH] - Versi 1.9.2+25
- Memperbaiki data `NAMA` agar memuat nama Kader yang ditarik secara benar dari field `namaKader` pada report provider.
- Merapikan pemformatan string Kelompok (memisahkan dengan spasi jika berderet).
- Memperbaiki proporsi lebar kolom tabel (UMUR, P, W) dan menyelaraskan baris persamaan penjumlahan agar tampak proporsional dan rapi seperti form standar fisik.

## [2026-07-07]
### [PATCH] - Versi 1.9.1+24
- Memperbaiki pengisian parameter periode, bulan, dan tahun pada form PDF Rekapitulasi Perincian/Ringkasan dan Profil Kependudukan Perincian/Ringkasan agar tercetak sesuai data waktu laporan saat *generate* PDF.

## [2026-07-07]
### [MINOR] - Versi 1.9.0+23
- Menambahkan utility `PdfFormBuilder` (`lib/core/utils/pdf_form_builder.dart`) sebagai standar pembuatan arsitektur UI tabel pada *generate* form PDF untuk menghindari bug tinggi *row* yang tidak sinkron dan menyederhanakan kode pada pengembangan form baru di masa mendatang. Utility ini mendukung kustomisasi perataan baris (*alignment*) pada header info dan cell tabel.

## [2026-07-07]
### [PATCH] - Versi 1.8.2+22
- Memperbaiki garis vertikal (border tabel) pada PDF Data Potensi Warga agar menyatu dan memiliki tinggi yang seragam dengan menggunakan struktur `pw.Table`.
- Memperbaiki urutan data bangunan pada Data Potensi Warga agar diurutkan berdasarkan `nomor_urut_bangunan` secara ASC.

## [2026-07-07]
### [PATCH] - Versi 1.8.1+21
- Fix Data Potensi Warga (Terisi) PDF: Seluruh struktur kolom diubah dari format lama (KRITERIA RUMAH, SUMBER AIR, MAKANAN POKOK, WARGA MENGIKUTI KEGIATAN) ke format yang benar sesuai form resmi Kelompok Dasawisma (NAMA BANGUNAN, JML KRT, JML KK, TOTAL L/P, BALITA, PUS, PENGGUNAAN ALAT KB, REMAJA 10-18 TH, LANSIA, BERKEBUTUHAN KHUSUS, KET — 30 kolom).
- Memperbaiki header info PDF dari RT/RW/Kelurahan/Kecamatan/Tahun menjadi NAMA KELOMPOK/RUKUN WARGA (RW)/DESA-KELURAHAN/TAHUN/PERIODE.

## [2026-07-06]
### [MINOR] - Versi 1.8.0+20
- Menambahkan kolom Umur pada halaman Profil Warga (View Individu).
- Memperbaiki rentang perhitungan umur sesuai standar pada algoritma rekap.
- Menambahkan Dropdown Pilihan Kader di dalam AppBar pada form Mutasi dan Lampid.
- Menyesuaikan layout info header PDF Laporan Perincian agar sejajar dengan teks.

## [2026-07-02]
### [PATCH] - Versi 1.7.3+19
- Fix Rekapitulasi PDF: "BoxConstraints forces an infinite height" - baris data dan baris total menggunakan `pw.CrossAxisAlignment.stretch` tanpa fixed height. Diperbaiki dengan menambahkan `height: 16` dan mengubah ke `CrossAxisAlignment.center`.
- Fix Data Potensi Warga PDF: semua data tampil "null" karena `getPotensiWargaData` hanya mengambil `id` dan `nama_bangunan` dari tabel bangunan, sementara PDF template membutuhkan field housing/infrastruktur (`rumahSehat`, `punyaTempatSampah`, `sumberAirPdam`, dll). Diperbaiki dengan `SELECT b.*` dan menambahkan semua field housing ke result map.
- Fix header Data Potensi Warga PDF: RT/RW/Kelurahan/Kecamatan/Tahun kini menampilkan data aktual dari region provider, bukan placeholder '...'.
- Fix Data Kuantitas header: kolom NAMA KRT / NAMA KEPALA KELUARGA otomatis berubah ke JUMLAH KRT / JUMLAH KEPALA KELUARGA saat mode Ringkasan.

## [2026-07-01]
### [PATCH] - Versi 1.7.2+18
- Menambahkan parameter tahun pada fungsi generateRekapPkkPerincianPdf.
- Membersihkan puluhan file script temporary/scratch di root direktori project.
- Memperbaiki linter (dart format & dart fix) untuk membersihkan peringatan kode.

## [2026-06-30]
### [PATCH] - Versi 1.6.3+15
- Memperbaiki Laporan Ringkasan Kuantitas: jumlah KRT/KK menggunakan tipe angka, dan header "NAMA" mencetak nama Kader/Pencatat.
- Memperbaiki Laporan Ringkasan Rekapitulasi: baris tabel KRT kini menampilkan Nama Kader (orang), bukan nama kelompok Dasawisma.
- Memperbaiki Laporan Ringkasan Potensi Warga: memperbaiki kolom NO agar tidak terhitung dalam Total, dan memperbaiki mapping data wilayah/bangunan.
- Memperbaiki Laporan Ringkasan Profil Kependudukan: mengubah format breakdown kolom umur per-kelompok ("a + b + c = total"), serta memperbaiki header Bulan/Tahun & Kelompok.
# Changelog

Semua perubahan yang signifikan pada proyek Dasawisma akan didokumentasikan dalam file ini.

## [2026-06-29]
### [PATCH] - Versi 1.6.2+14
- Memperbaiki error type cast (String menjadi int?) di pdf_report_service.dart dengan menambahkan helper parsing aman untuk mencegah crash pada data Potensi Warga.
- Menambahkan baris kosong (padding) pada form Ringkasan agar tabel memanjang penuh ke bawah form secara profesional.
- Memperbaiki layout dan lebar kolom pada halaman PDF Ringkasan Kuantitas.
## [2026-06-29]
### [MINOR] - Versi 1.6.0+12
- Menambahkan fitur Cetak Laporan Ringkasan (Rekap per Kader Tingkat RT/RW).
- Melakukan agregasi data (Form 3, Rekap PKK, Profil Penduduk, Potensi Warga, Lampid) sesuai pilihan kader.
- Memperbaiki query filter `getForm1Data` dan `getForm2Data` yang gagal mem-filter semua rt/rw dengan benar.
- Memperbaiki `local_db_helper.dart` versi 11.

## [2026-06-28]
### [PATCH] - Versi 1.4.1+6
- Perbaikan total layout tabel PDF Rekapitulasi (Terisi): migrasi dari width statis ke Expanded(flex) proporsional.
- Perbaikan kolom TOTAL/BALITA agar L dan P terbagi rata (50:50).
- Perbaikan info header (DASA WISMA, RT, RW) menggunakan label lebar tetap agar titik dua sejajar.
- Perbaikan font PEMANFAATAN TANAH PEKARANGAN agar muat dalam kolom.
- Perbaikan border tabel: tinggi baris tetap (14pt) + CrossAxisAlignment.stretch + Container pembungkus border luar.
- Perbaikan kolom Sumber Air (wKriteria → wAge) agar sejajar dengan header.
- Perbaikan parsing CSV import untuk luas_bangunan dan luas_tanah (handle koma sebagai desimal).
- Kolom KET diisi default '0'.

## [2026-06-22]
### [MINOR] - Versi 1.2.0+1
- Pembaruan skema `local_db_helper.dart` menjadi versi 10 untuk mendukung pencatatan data Bantuan Sosial yang lebih detail.
- Perubahan atribut pada entitas dan model `Individu` (jenisBantuan, tglBantuan, lamaBantuan, jumlahBantuan).
- Penambahan "Bagian 5: Bantuan Sosial" pada `FormIndividuScreen` dengan isian jenis, tanggal, lama, dan jumlah bantuan.

## [2026-06-04]
### [MINOR] - Versi 0.9.0+1
- Penambahan UI Mutasi Demografi (FormMutasiScreen).
- Pembaruan DetailBangunanScreen menggunakan tab untuk menampilkan daftar KRT dan Riwayat Mutasi.
- Penambahan app route untuk `/form-mutasi/:bangunanId`.

## [2026-06-04]
### [MINOR] - Versi 0.7.0+1
- Penambahan entitas Kepala Rumah Tangga (KRT) ke dalam struktur arsitektur data. Hierarki pendataan kini menjadi: **Bangunan → KRT → Keluarga (KK) → Individu**.
- Pembaruan `local_db_helper` untuk menampung tabel `krt` dan memigrasikan foreign key `keluarga` ke `id_krt`.
- Pembuatan `FormKrtScreen` dan `DetailKrtScreen`.
- Pembaruan `DetailBangunanScreen` dan `FormKeluargaScreen` untuk mengakomodasi alur KRT.
- Penambahan isian NIK dan No KK pada entitas KRT.

## [2026-06-04]
### [MINOR] - Versi 0.6.0+1
- Implementasi lengkap 3 Form Pendataan (Drill-down):
  - **FormBangunanScreen**: Form input data bangunan dengan 3 bagian (Identitas & Lokasi, Legalitas & Fisik, Sanitasi & Kriteria Rumah).
  - **FormKeluargaScreen**: Form input data Kartu Keluarga (KK) per bangunan.
  - **FormIndividuScreen**: Form input data individu dengan 4 bagian ExpansionTile (Biodata, Demografi, Kesehatan/3 Buta, KB).
- Implementasi 2 Halaman Detail (Drill-down):
  - **DetailBangunanScreen**: Menampilkan ringkasan bangunan dan daftar KK di dalamnya.
  - **DetailKeluargaScreen**: Menampilkan info KK dan daftar individu/anggota keluarga.
- Pembuatan Repository lokal (SQLite) untuk Bangunan, Keluarga, dan Individu.
- Pembuatan Riverpod Provider untuk ketiga entitas.
- PendataanScreen diperbarui menjadi daftar bangunan fungsional dengan FAB.
- Integrasi 5 rute baru di `app_router.dart` (form & detail screens di luar ShellRoute).
- Perbaikan 3 deprecation warning (`DropdownButtonFormField.value` → `initialValue`).
- Perbaikan import path menggunakan `package:dawis/` untuk konsistensi.

## [2026-06-02]
### [MINOR] - Versi 0.5.0+1
- Penambahan parameter Demografi dan Sosial Kesehatan pada entitas `Individu`:
  - `metode_kb` dan `alasan_bukan_kb` untuk pendataan Keluarga Berencana.
  - `is_buta_huruf`, `is_buta_angka`, `is_buta_bahasa` untuk pendataan 3 Buta.
  - `kriteria_berkebutuhan_khusus` untuk pencatatan warga disabilitas/kebutuhan khusus.
  - `makanan_pokok` untuk data konsumsi harian.
- Penambahan kembali `sumber_air_minum` pada entitas `Bangunan` sesuai koreksi pengguna.
- Pembersihan parameter `jenis_kloset` dari entitas `Bangunan`.

### [MINOR] - Versi 0.4.0+1
- Integrasi Skema Standar Aplikasi Carik pada entitas `Bangunan`.
- Menambahkan parameter legalitas dan fisik: `nop_pbb`, `luas_bangunan`, `luas_tanah`.
- Menambahkan parameter status & sanitasi: `status_kepemilikan`, `jenis_kloset`, `jumlah_fasilitas_bab`.
- Menambahkan parameter `pemanfaatan_pekarangan` untuk menampung pilihan jamak (contoh: "TOGA, Warung Hidup") dalam format *String* CSV.
- Penambahan 6 parameter *binary* (0/1) untuk indikator kelayakan hunian "Kriteria Rumah":
  1. `is_sehat_layak_huni`
  2. `is_tidak_sehat_layak_huni`
  3. `has_tempat_sampah`
  4. `has_spal`
  5. `has_jamban_keluarga`
  6. `has_stiker_p4k`

### [MINOR] - Versi 0.3.0+1
- Revisi skema database `Bangunan` dengan penambahan kolom `kelompok_dawis` untuk memfasilitasi filter wilayah kerja (Role-Based Access Control).
- Revisi skema database `Individu` dengan penambahan kolom `tempat_lahir` dan `bantuan_sosial`.
- Pembaruan semua Entitas dan Model Data (DTO) terkait dengan kolom-kolom baru.
- Penambahan tipe konstanta `BantuanSosialConstants` (PKH, BPNT, PBI JK/KIS, PIP, BLT, BANTUAN PANGAN).
- Pembuatan antarmuka Halaman Login (`LoginScreen`) sebagai gerbang awal persiapan autentikasi Supabase.
- Pengaturan rute `/login` sebagai *Initial Location* di `app_router.dart`.

## [2026-06-01]
### [MINOR] - Versi 0.2.0+1
- Integrasi `go_router` untuk struktur navigasi fitur (Dashboard & Pendataan).
- Pembuatan layout responsif untuk Mobile (`BottomNavigationBar`) dan Desktop/Web (`NavigationRail`).
- Pembuatan antarmuka pengguna (`DashboardScreen`) terintegrasi penuh dengan Riverpod `AsyncValue` untuk menampilkan agregasi data Dasawisma.
- Pembuatan antarmuka sementara (`PendataanScreen`) untuk daftar data Bangunan.
- Modifikasi `main.dart` untuk membungkus kerangka dengan `ProviderScope` dan `MaterialApp.router`.

### [MAJOR] - Versi 0.1.0+1
- Inisialisasi Proyek Dasawisma menggunakan arsitektur Clean Architecture (Feature-first).
- Implementasi dukungan Offline-First menggunakan SQLite (`sqflite` dan `sqflite_common_ffi_web`).
- Implementasi Supabase Client Setup.
- Pembuatan Core Entities dan Models (DTO) untuk Bangunan, Keluarga, Individu.
- Pembuatan Repositori Dasawisma dan Riverpod Provider untuk fungsi agregasi *dashboard* rekapan Dasawisma.

[2026-06-04] [MINOR] Menambahkan modul autentikasi Supabase dan sinkronisasi ID Kader pada Form Bangunan.

[2026-06-04] [PATCH] Menambahkan isolasi akses data (Data Scoping) agar kader hanya bisa melihat daftar Bangunan miliknya sendiri.

[2026-06-04] [PATCH] Finalisasi Integrasi UI Mutasi dengan Detail Keluarga. Membantu penghapusan data secara otomatis jika individu dinyatakan Pindah atau Meninggal.

[2026-06-04] [MINOR] Menambahkan layanan Export/Import Excel (ExcelReportService & DataTransferService).
[ 2 0 2 6 - 0 6 - 2 9 ]   [ P A T C H ]   F i x e d   s y n t a x   e r r o r s   i n   p d f _ r e p o r t _ s e r v i c e ,   h a s h e d   d e f a u l t   p a s s w o r d s ,   a n d   s t a n d a r d i z e d   d a t a b a s e   q u e r i e s   b a s e d   o n   A G E N T S . m d   r u l e s .  
 [ 2 0 2 6 - 0 6 - 2 9 ]   [ P A T C H ]   -   V e r s i   1 . 4 . 3 + 8  
 -   M e r o m b a k   u l a n g   U I   \ s e t t i n g s _ s c r e e n . d a r t \   m e n j a d i   l e b i h   m o d e r n   d e n g a n   l a y o u t   g r i d   d u a   k o l o m   d a n   p r o f i l   c a r d   k h u s u s .  
 -   M e n g h a p u s   t o m b o l   ' B u k a   L a p o r a n   &   E k s p o r   D a t a '   d i   h a l a m a n   D a s h b o a r d .  
 -   M e r o m b a k   \ d e t a i l _ b a n g u n a n _ s c r e e n . d a r t \   u n t u k   m e n g a d o p s i   U I   c a r d   p r o f i l e   b a r u   d e n g a n   l a y o u t   k o l o m   r e s p o n s i f   u n t u k   i n f o r m a s i   u m u m   d a n   l i n g k u n g a n .  
 -   M e m p e r b a i k i   l a y o u t   h e a d e r   P D F   F o r m   ' A n a k   Y a t i m   P i a t u '   m e n j a d i   2   k o l o m   d a n   m e m a s t i k a n   t a b e l   m e n c e t a k   s e t i d a k n y a   1 5   b a r i s   k o s o n g   s e b a g a i   _ p l a c e h o l d e r _   c e t a k .  
 -   M e m p e r b a i k i   b u g   g a r i s   p i n g g i r   g a n d a   ( d o u b l e   b o r d e r s )   p a d a   t a b e l   l a p o r a n   P D F   Y a t i m   P i a t u .  
 -   M e n a m b a l   b u g   d i   m a n a   v a r i a b e l   t e k s   t i d a k   d i c e t a k   d i   d a l a m   h e a d e r   P D F   c e t a k a n   f o r m u l i r   u t a m a .  
 


## [1.7.0] - 2026-06-30
### Changed
- Refactored Data Kuantitas (Form 3), Rekapitulasi (Tingkat RW), and Potensi Warga PDF generation layouts.
- Updated demographics ranges: Remaja (10-24), Pra Lansia (45-59).
