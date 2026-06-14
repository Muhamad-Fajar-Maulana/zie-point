import 'package:flutter/material.dart';
import '../models/siswa.dart';
import '../models/catatan_siswa.dart';
import '../models/jenis_catatan.dart';
import '../services/api_service.dart';

class SiswaDetailPage extends StatefulWidget {
  final Siswa siswa;
  const SiswaDetailPage({super.key, required this.siswa});

  @override
  State<SiswaDetailPage> createState() => _SiswaDetailPageState();
}

class _SiswaDetailPageState extends State<SiswaDetailPage> {
  List<CatatanSiswa> _riwayat = [];
  bool _isLoading = true;
  int _totalPoin = 0;

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getCatatanSiswa(widget.siswa.id!);
      
      int poinCalc = 0;
      for (var item in data) {
        poinCalc += (item.poin ?? 0);
      }

      setState(() {
        _riwayat = data;
        _totalPoin = poinCalc;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Color _getBadgeColor(int poin) {
    if (poin >= 75) return const Color(0xFFDC3545);
    if (poin >= 40) return const Color(0xFFE8590C);
    if (poin >= 25) return const Color(0xFF0077B6);
    return const Color(0xFF2D6A4F);
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null) return '-';
    return rawDate.split('T')[0]; // Simple YYYY-MM-DD format
  }

  void _showCatatPelanggaranForm() async {
    // Ambil daftar pelanggaran dari API terlebih dahulu
    List<JenisCatatan> jenisList = [];
    try {
      jenisList = await ApiService.getJenisCatatan('pelanggaran');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat daftar pelanggaran')));
      return;
    }

    if (!mounted) return;

    JenisCatatan? selectedJenis;
    final ketCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Catat Pelanggaran Baru',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B2A4A)),
                  ),
                  const SizedBox(height: 20),
                  const Text('Pilih Pelanggaran', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<JenisCatatan>(
                        isExpanded: true,
                        hint: const Text('Silakan pilih...'),
                        value: selectedJenis,
                        items: jenisList.map((j) {
                          return DropdownMenuItem<JenisCatatan>(
                            value: j,
                            child: Text('${j.nama} (+${j.poin} Poin)'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setModalState(() {
                            selectedJenis = val;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Keterangan Tambahan (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ketCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Misal: Terlambat marah-marah',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B2A4A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: selectedJenis == null ? null : () async {
                        final data = CatatanSiswa(
                          idSiswa: widget.siswa.id!,
                          idJenis: selectedJenis!.id!,
                          keterangan: ketCtrl.text.trim(),
                        );
                        try {
                          await ApiService.addCatatanSiswa(data);
                          if (mounted) {
                            Navigator.pop(ctx);
                            _loadRiwayat();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pelanggaran berhasil dicatat!')));
                          }
                        } catch (e) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                      child: const Text('Simpan Rekaman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Profil Siswa', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B2A4A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF1B2A4A),
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white24,
                    child: Text(
                      widget.siswa.nama.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.siswa.nama,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                              child: Text('Kelas: ${widget.siswa.kelas}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                              child: Text('NIS: ${widget.siswa.nis}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Poin Penalti', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Akumulasi pelanggaran', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getBadgeColor(_totalPoin).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _totalPoin.toString(),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _getBadgeColor(_totalPoin)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: const Text('Riwayat Catatan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B2A4A))),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_riwayat.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 64, color: Colors.green[300]),
                    const SizedBox(height: 16),
                    Text('Siswa teladan!', style: TextStyle(color: Colors.grey[700], fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Belum ada riwayat pelanggaran tercatat.', style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _riwayat[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(left: BorderSide(color: const Color(0xFF0077B6), width: 4)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(item.namaPelanggaran ?? 'Pelanggaran', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Tanggal: ${_formatDate(item.tanggal)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            if (item.keterangan != null && item.keterangan!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Info: ${item.keterangan}', style: TextStyle(color: Colors.grey[800], fontSize: 12, fontStyle: FontStyle.italic)),
                            ]
                          ],
                        ),
                        trailing: Text('+${item.poin}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  );
                },
                childCount: _riwayat.length,
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)), // Padding for FAB
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCatatPelanggaranForm,
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.assignment_add),
        label: const Text('Catat Pelanggaran', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
