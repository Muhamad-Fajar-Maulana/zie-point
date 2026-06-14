class CatatanSiswa {
  final int? idCatatan;
  final int? idGuru;
  final int idSiswa;
  final int idJenis;
  final String? tanggal;
  final String? keterangan;

  // Bidang tambahan (JOIN dari tabel jenis_catatan)
  final String? namaPelanggaran;
  final int? poin;

  CatatanSiswa({
    this.idCatatan,
    this.idGuru,
    required this.idSiswa,
    required this.idJenis,
    this.tanggal,
    this.keterangan,
    this.namaPelanggaran,
    this.poin,
  });

  factory CatatanSiswa.fromJson(Map<String, dynamic> json) {
    return CatatanSiswa(
      idCatatan: json['id_catatan'],
      idGuru: json['id_guru'],
      idSiswa: json['id_siswa'],
      idJenis: json['id_jenis'],
      tanggal: json['tanggal'],
      keterangan: json['keterangan'],
      namaPelanggaran: json['nama_pelanggaran'],
      poin: json['poin'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id_siswa': idSiswa,
        'id_jenis': idJenis,
        'keterangan': keterangan,
      };
}
