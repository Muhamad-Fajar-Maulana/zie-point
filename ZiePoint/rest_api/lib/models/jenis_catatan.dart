class JenisCatatan {
  final int? id;
  final String nama;
  final String? deskripsi;
  final int poin;
  final String tipe;

  JenisCatatan({
    this.id,
    required this.nama,
    this.deskripsi,
    required this.poin,
    required this.tipe,
  });

  factory JenisCatatan.fromJson(Map<String, dynamic> json) {
    return JenisCatatan(
      id: json['id_jenis'] ?? json['id'],
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'],
      poin: json['poin'] is int ? json['poin'] : int.tryParse(json['poin'].toString()) ?? 0,
      tipe: json['tipe'] ?? '',
    );
  }
}
