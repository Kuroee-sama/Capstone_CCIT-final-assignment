import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaksi_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});
  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<TransaksiModel> _list = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      _isAdmin = await AuthService.isAdmin();
      final data = _isAdmin ? await ApiService.getAllTransaksi() : await ApiService.getMyTransaksi();
      if (mounted) setState(() { _list = data; _isLoading = false; });
    } catch (_) { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final df = DateFormat('dd MMM yyyy, HH:mm');
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Riwayat Transaksi', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D3436))),
        backgroundColor: Colors.white, elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF2D3436)),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22)))
        : _list.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('Belum ada riwayat transaksi', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            ]))
          : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFFE67E22),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _list.length,
                itemBuilder: (_, i) {
                  final t = _list[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      leading: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.receipt, color: Color(0xFFE67E22)),
                      ),
                      title: Text('#${t.transaksiId}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(df.format(t.tglTransaksi), style: const TextStyle(fontSize: 12, color: Color(0xFF636E72))),
                          if (_isAdmin && t.karyawanUsername != null)
                            Text('Kasir: ${t.karyawanUsername}', style: const TextStyle(fontSize: 12, color: Color(0xFF636E72))),
                        ],
                      ),
                      trailing: Text(f.format(t.totalAmount), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFFE67E22))),
                      onTap: () => _showDetail(t),
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _showDetail(TransaksiModel t) async {
    try {
      final detail = await ApiService.getTransaksiDetail(t.transaksiId);
      if (!mounted) return;
      final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
      showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.6, maxChildSize: 0.9, minChildSize: 0.3, expand: false,
          builder: (_, ctrl) => ListView(controller: ctrl, padding: const EdgeInsets.all(24), children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            Text('Transaksi #${detail.transaksiId}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(DateFormat('dd MMM yyyy, HH:mm').format(detail.tglTransaksi), style: const TextStyle(color: Color(0xFF636E72))),
            const SizedBox(height: 20),
            if (detail.detailList != null) ...detail.detailList!.map((d) => Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F2F6)))),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.namaItem, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${f.format(d.harga)} x ${d.jumlah}', style: const TextStyle(fontSize: 12, color: Color(0xFF636E72))),
                ])),
                Text(f.format(d.totalHarga), style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
            )),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('TOTAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Text(f.format(detail.totalAmount), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFFE67E22))),
            ]),
          ]),
        ),
      );
    } catch (_) {}
  }
}
