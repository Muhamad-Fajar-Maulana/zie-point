import 'package:flutter/material.dart';
import '../models/siswa.dart';
import '../services/api_service.dart';
import 'siswa_detail_page.dart';

class SiswaPage extends StatefulWidget {
  const SiswaPage({super.key});

  @override
  State<SiswaPage> createState() => _SiswaPageState();
}

class _SiswaPageState extends State<SiswaPage> {
  List<Siswa> _siswaList = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSiswa();
  }

  Future<void> _loadSiswa() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getSiswa();
      setState(() {
        _siswaList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat data: $e');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showForm({Siswa? siswa}) {
    final namaCtrl = TextEditingController(text: siswa?.nama);
    final kelasCtrl = TextEditingController(text: siswa?.kelas);
    final nisCtrl = TextEditingController(text: siswa?.nis);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar form tidak tertutup keyboard
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                siswa == null ? 'Tambah Siswa Baru' : 'Edit Data Siswa',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2A4A),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: namaCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: kelasCtrl,
                      decoration: InputDecoration(
                        labelText: 'Kelas (Misal: 10A)',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: nisCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'NIS',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B2A4A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (namaCtrl.text.isEmpty ||
                        kelasCtrl.text.isEmpty ||
                        nisCtrl.text.isEmpty) {
                      _showSnackBar('Harap isi semua kolom!');
                      return;
                    }

                    final data = Siswa(
                      nama: namaCtrl.text.trim(),
                      kelas: kelasCtrl.text.trim(),
                      nis: nisCtrl.text.trim(),
                    );
                    try {
                      if (siswa == null) {
                        await ApiService.addSiswa(data);
                        _showSnackBar('Data berhasil ditambahkan!');
                      } else {
                        await ApiService.updateSiswa(siswa.id!, data);
                        _showSnackBar('Data berhasil diperbarui!');
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      _loadSiswa();
                    } catch (e) {
                      _showSnackBar('Error: $e');
                    }
                  },
                  child: Text(
                    siswa == null ? 'Simpan Data' : 'Perbarui Data',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteSiswa(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Siswa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Yakin ingin menghapus data siswa ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.deleteSiswa(id);
      _showSnackBar('Data berhasil dihapus!');
      _loadSiswa();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _siswaList.where((s) {
      return s.nama.toLowerCase().contains(_searchQuery.toLowerCase()) || 
             s.nis.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Serasi dengan JenisCatatanPage
      appBar: AppBar(
        title: const Text('Data Siswa', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B2A4A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSiswa,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B2A4A)))
          : RefreshIndicator(
              onRefresh: _loadSiswa,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header Melengkung Premium ---
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B2A4A),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daftar Semua\nSiswa',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Kelola data siswa ZiePoint, tambahkan, perbarui, atau hapus apabila diperlukan.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Search Bar
                        TextField(
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari nama atau NIS siswa...',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF1B2A4A)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- List Data Siswa ---
                  Expanded(
                    child: filteredList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  _siswaList.isEmpty ? 'Belum ada data siswa' : 'Siswa tidak ditemukan',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 80), // padding bawah untuk FAB
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final s = filteredList[index];
                              return _buildSiswaCard(s);
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF1B2A4A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSiswaCard(Siswa s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SiswaDetailPage(siswa: s),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4ED), // Latar avatar pastel
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Text(
                  '${s.id}',
                  style: const TextStyle(
                    color: Color(0xFF1B2A4A),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info Siswa
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.nama,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.class_outlined, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        'Kelas: ${s.kelas}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.badge_outlined, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        'NIS: ${s.nis}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Aksi Edit & Delete
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_note),
                  color: const Color(0xFF0077B6),
                  onPressed: () => _showForm(siswa: s),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.redAccent,
                  onPressed: () => _deleteSiswa(s.id!),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
