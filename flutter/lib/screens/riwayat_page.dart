import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaksi_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'riwayat_detail_page.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<TransaksiModel> _list = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final isAdmin = await AuthService.isAdmin();
      final data = await ApiService.getRiwayatTransaksi(size: 200);

      if (!mounted) return;
      setState(() {
        _isAdmin = isAdmin;
        _list = data;
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

  Future<void> _confirmDelete(TransaksiModel transaksi) async {
    if (!_isAdmin) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Hapus Transaksi #${transaksi.transaksiId}?'),
        content: const Text('Data transaksi dan detail item akan dihapus. Stok menu akan dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete, size: 17),
            label: const Text('Hapus'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ApiService.deleteTransaksi(transaksi.transaksiId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaksi #${transaksi.transaksiId} berhasil dihapus')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D3436)),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF2D3436)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22)))
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _load)
              : _list.isEmpty
                  ? const _EmptyState()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: const Color(0xFFE67E22),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: isWide ? 1100 : double.infinity),
                          child: isWide
                              ? _buildTable(currencyFormat, dateFormat)
                              : _buildMobileList(currencyFormat, dateFormat),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildMobileList(NumberFormat currencyFormat, DateFormat dateFormat) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _list.length,
      itemBuilder: (_, i) {
        final transaksi = _list[i];
        return _MobileTransactionCard(
          transaksi: transaksi,
          formatter: currencyFormat,
          dateFormatter: dateFormat,
          canDelete: _isAdmin,
          onDetail: () => _openDetail(transaksi),
          onDelete: () => _confirmDelete(transaksi),
        );
      },
    );
  }

  Widget _buildTable(NumberFormat currencyFormat, DateFormat dateFormat) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
              columns: const [
                DataColumn(label: Text('No')),
                DataColumn(label: Text('ID Transaksi')),
                DataColumn(label: Text('Tanggal')),
                DataColumn(label: Text('Kasir')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Aksi')),
              ],
              rows: _list.asMap().entries.map((entry) {
                final index = entry.key;
                final transaksi = entry.value;
                return DataRow(cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(Text('#${transaksi.transaksiId}', style: const TextStyle(fontWeight: FontWeight.w800))),
                  DataCell(Text(dateFormat.format(transaksi.tglTransaksi))),
                  DataCell(Text(transaksi.karyawanUsername ?? '-')),
                  DataCell(Text(
                    currencyFormat.format(transaksi.totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  )),
                  DataCell(
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        TextButton.icon(
                          onPressed: () => _openDetail(transaksi),
                          icon: const Icon(Icons.visibility, size: 17),
                          label: const Text('Detail'),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFE3F2FD),
                            foregroundColor: const Color(0xFF2196F3),
                          ),
                        ),
                        if (_isAdmin)
                          TextButton.icon(
                            onPressed: () => _confirmDelete(transaksi),
                            icon: const Icon(Icons.delete, size: 17),
                            label: const Text('Hapus'),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFFFF5F5),
                              foregroundColor: const Color(0xFFE74C3C),
                            ),
                          ),
                      ],
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _openDetail(TransaksiModel transaksi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RiwayatDetailPage(
          transaksiId: transaksi.transaksiId,
          initialData: transaksi,
        ),
      ),
    );
  }
}

class _MobileTransactionCard extends StatelessWidget {
  final TransaksiModel transaksi;
  final NumberFormat formatter;
  final DateFormat dateFormatter;
  final bool canDelete;
  final VoidCallback onDetail;
  final VoidCallback onDelete;

  const _MobileTransactionCard({
    required this.transaksi,
    required this.formatter,
    required this.dateFormatter,
    required this.canDelete,
    required this.onDetail,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDetail,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.receipt, color: Color(0xFFE67E22), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '#${transaksi.transaksiId}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF2D3436)),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            dateFormatter.format(transaksi.tglTransaksi),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF636E72)),
                          ),
                          Text(
                            'Kasir: ${transaksi.karyawanUsername ?? '-'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF636E72)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 116),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatter.format(transaksi.totalAmount),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFFE67E22)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionPill(
                        label: 'Detail',
                        icon: Icons.visibility,
                        color: const Color(0xFF2196F3),
                        backgroundColor: const Color(0xFFE3F2FD),
                        onTap: onDetail,
                      ),
                    ),
                    if (canDelete) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionPill(
                          label: 'Hapus',
                          icon: Icons.delete,
                          color: const Color(0xFFE74C3C),
                          backgroundColor: const Color(0xFFFFF5F5),
                          onTap: onDelete,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ActionPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Belum ada riwayat transaksi', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
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
