1. Model menyimpan data beserta aturan.
View hanya menampilkan informasi dan meneruskan tindakan pengguna sedangkan 
ViewModel menghubungkan keduanya dengan menentukan apa yang terjadi saat pengguna meminjam atau mengembalikan buku, serta menyediakan status yang diperlukan oleh View.

2. `LoanCard.build()` dijalankan setiap kali Flutter menggambar ulang widget. Jika perhitungan dilakukan di sana, logika bisnis akan tercampur dan berisiko. ViewModel yang seharusnya bertugas menghitung denda, sementara card hanya perlu menampilkan nilai yang diterima.

3. ViewModel harus menolak permintaan tersebut, mengembalikan nilai `false`, dan memberikan pesan kesalahan seperti "Buku sedang dipinjam," tanpa membuat catatan peminjaman baru. Selanjutnya, UI akan menampilkan pesan tersebut kepada siswa.

4. Jika rumus perhitungan digunakan berulang kali di berbagai tempat, perubahan apapun yang terjadi harus diterapkan di setiap lokasi. Jika ada satu tempat yang terlewat, nilai yang ditampilkan di layar akan menjadi tidak konsisten dan berbeda-beda. Dengan memusatkan implementasi di dalam `FineService`, setiap layar dan perhitungan total akan selalu menggunakan hasil yang sama.

5. Sebuah buku dianggap overdue jika melewati tanggal jatuh tempo tetapi belum mencapai batas enam bulan; dalam kondisi ini, siswa dikenakan denda mingguan dan buku masih dapat dikembalikan seperti biasa. Buku dianggap "hilang" (missing) jika sudah terlambat dikembalikan selama enam bulan, sehingga siswa wajib membayar harga penggantian penuh ditambah dengan denda mingguan.

6. Dengan mengubah konstanta `weeklyFine` di dalam `Fine` dari 5000 menjadi 7000, karena `FineService` mengambil nilai tersebut dari sana. Setelah itu, jalankan test, karena nilai yang diharapkan dalam pengujian denda (seperti Rp5.000 dan Rp10.000) juga harus diperbarui menjadi Rp7.000 dan Rp14.000.