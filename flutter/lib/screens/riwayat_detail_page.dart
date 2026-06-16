import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaksi_model.dart';
import '../services/api_service.dart';

class RiwayatDetailPage extends StatefulWidget {
  final int transaksiId;
  final TransaksiModel? initialData;

  const RiwayatDetailPage({
    super.key,
    required this.transaksiId,
    this.initialData,
  });

  @override
  State<RiwayatDetailPage> createState() => _RiwayatDetailPageState();
}

class _RiwayatDetailPageState extends State<RiwayatDetailPage> {
  TransaksiModel? _transaksi;
  List<DetailTransaksiModel> _details = [];
  bool _isLoading = true;
  String? _error;

  final NumberFormat _money = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    _transaksi = widget.initialData;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getTransaksiDetail(widget.transaksiId),
        ApiService.getTransaksiDetails(widget.transaksiId),
      ]);

      if (!mounted) return;
      setState(() {
        _transaksi = results[0] as TransaksiModel;
        _details = results[1] as List<DetailTransaksiModel>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width >= 900 ? 820.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Detail Transaksi #${widget.transaksiId}',
          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D3436)),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF2D3436)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22)))
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  color: const Color(0xFFE67E22),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: ListView(
                        padding: const EdgeInsets.all(18),
                        children: [
                          _InfoCard(
                            transaksi: _transaksi,
                            money: _money,
                            dateFormat: _dateFormat,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Item yang Dibeli',
                            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF2D3436)),
                          ),
                          const SizedBox(height: 14),
                          _DetailItemsCard(details: _details, money: _money),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final TransaksiModel? transaksi;
  final NumberFormat money;
  final DateFormat dateFormat;

  const _InfoCard({required this.transaksi, required this.money, required this.dateFormat});

  @override
  Widget build(BuildContext context) {
    final t = transaksi;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 18,
        children: [
          _InfoItem(
            label: 'Tanggal Transaksi',
            value: t == null ? '-' : dateFormat.format(t.tglTransaksi),
          ),
          _InfoItem(
            label: 'Kasir',
            value: t?.karyawanUsername ?? '-',
          ),
          _InfoItem(
            label: 'Metode Pembayaran',
            value: t?.metodePembayaran ?? 'CASH',
          ),
          _InfoItem(
            label: 'Total Pembayaran',
            value: t == null ? '-' : money.format(t.totalAmount),
            highlight: true,
          ),
          if (t?.bayar != null)
            _InfoItem(label: 'Bayar', value: money.format(t!.bayar!)),
          if (t?.kembalian != null)
            _InfoItem(label: 'Kembalian', value: money.format(t!.kembalian!)),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _InfoItem({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 11, letterSpacing: 0.5, fontWeight: FontWeight.w700, color: Color(0xFF636E72)),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 20 : 16,
              fontWeight: FontWeight.w800,
              color: highlight ? const Color(0xFFE67E22) : const Color(0xFF2D3436),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItemsCard extends StatelessWidget {
  final List<DetailTransaksiModel> details;
  final NumberFormat money;

  const _DetailItemsCard({required this.details, required this.money});

  @override
  Widget build(BuildContext context) {
    if (details.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Text('Detail item transaksi tidak tersedia.', style: TextStyle(color: Color(0xFF636E72))),
      );
    }

    final isWide = MediaQuery.sizeOf(context).width >= 720;
    if (!isWide) {
      return _MobileDetailList(details: details, money: money);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
          columns: const [
            DataColumn(label: Text('No')),
            DataColumn(label: Text('Nama Item')),
            DataColumn(label: Text('Kategori')),
            DataColumn(label: Text('Harga')),
            DataColumn(label: Text('Jumlah')),
            DataColumn(label: Text('Subtotal')),
          ],
          rows: details.asMap().entries.map((entry) {
            final index = entry.key;
            final d = entry.value;
            return DataRow(cells: [
              DataCell(Text('${index + 1}')),
              DataCell(Text(d.namaItem, style: const TextStyle(fontWeight: FontWeight.w800))),
              DataCell(_CategoryBadge(text: d.namaKategori)),
              DataCell(Text(money.format(d.harga))),
              DataCell(Text('${d.jumlah}')),
              DataCell(Text(money.format(d.totalHarga), style: const TextStyle(fontWeight: FontWeight.w800))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class _MobileDetailList extends StatelessWidget {
  final List<DetailTransaksiModel> details;
  final NumberFormat money;

  const _MobileDetailList({required this.details, required this.money});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: details.map((d) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(d.namaItem, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                  Text(money.format(d.totalHarga), style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFE67E22))),
                ],
              ),
              const SizedBox(height: 8),
              _CategoryBadge(text: d.namaKategori),
              const SizedBox(height: 10),
              Text('${money.format(d.harga)} x ${d.jumlah}', style: const TextStyle(color: Color(0xFF636E72))),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String text;
  const _CategoryBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(7)),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFE67E22)),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFE74C3C), size: 54),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF636E72))),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE67E22), foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
