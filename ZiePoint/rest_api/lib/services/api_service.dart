import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/siswa.dart';
import '../models/jenis_catatan.dart';
import '../models/catatan_siswa.dart';

class ApiService {
  // Ganti dengan IP komputer kamu jika pakai HP fisik
  // DevicebaseUrl
  //Browser (Web) http://localhost:3000
  //Emulator Android http://10.0.2.2:3000
  //HP Fisik http://192.168.x.x:3000 (IP komputer)
  static const String baseUrl = 'http://localhost:3000';

  // --- Siswa ---
  static Future<List<Siswa>> getSiswa() async {
    final res = await http.get(Uri.parse('$baseUrl/siswa'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Siswa.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat data siswa');
  }

  static Future<void> addSiswa(Siswa siswa) async {
    final res = await http.post(
      Uri.parse('$baseUrl/siswa'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(siswa.toJson()),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Gagal menambahkan data siswa');
    }
  }

  static Future<void> updateSiswa(int id, Siswa siswa) async {
    final res = await http.put(
      Uri.parse('$baseUrl/siswa/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(siswa.toJson()),
    );
    if (res.statusCode != 200) {
      throw Exception('Gagal memperbarui data siswa');
    }
  }

  static Future<void> deleteSiswa(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/siswa/$id'));
    if (res.statusCode != 200) {
      throw Exception('Gagal menghapus data siswa');
    }
  }

  // --- Jenis Catatan ---
  static Future<List<JenisCatatan>> getJenisCatatan(String tipe) async {
    final res = await http.get(Uri.parse('$baseUrl/jenis_catatan/$tipe'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => JenisCatatan.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat data jenis catatan');
  }

  // --- Riwayat Transaksi ---
  static Future<List<CatatanSiswa>> getCatatanSiswa(int idSiswa) async {
    final res = await http.get(Uri.parse('$baseUrl/catatan_siswa/siswa/$idSiswa'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => CatatanSiswa.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat riwayat pelanggaran');
  }

  static Future<void> addCatatanSiswa(CatatanSiswa catatan) async {
    final res = await http.post(
      Uri.parse('$baseUrl/catatan_siswa'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(catatan.toJson()),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Gagal mencatat pelanggaran');
    }
  }
}
