import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class PendapatanPage extends StatefulWidget {
  const PendapatanPage({super.key});

  @override
  State<PendapatanPage> createState() => _PendapatanPageState();
}

class _PendapatanPageState extends State<PendapatanPage> {
  List<_MonthlyIncome> _monthly = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getMonthlyIncome();
      if (!mounted) return;
      setState(() {
        _monthly = data.map(_MonthlyIncome.fromJson).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final total = _monthly.fold<double>(0, (sum, item) => sum + item.totalPendapatan);
    final totalTransaksi = _monthly.fold<int>(0, (sum, item) => sum + item.jumlahTransaksi);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Pendapatan Bulanan', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D3436))),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF2D3436)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22)))
          : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFFE67E22),
              child: ListView(
                padding: const EdgeInsets.all(30),
                children: [
                  _Header(onBack: () => Navigator.maybePop(context)),
                  const SizedBox(height: 28),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final isDesktop = width >= 900;
                      return Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          _SummaryCard(width: isDesktop ? (width - 40) / 3 : width, label: 'Total Pendapatan Keseluruhan', value: f.format(total), icon: Icons.money, color: const Color(0xFFE67E22), bgColor: const Color(0xFFFFF3E0)),
                          _SummaryCard(width: isDesktop ? (width - 40) / 3 : width, label: 'Total Transaksi', value: '$totalTransaksi', icon: Icons.receipt_long, color: const Color(0xFF3498DB), bgColor: const Color(0xFFE3F2FD)),
                          _SummaryCard(width: isDesktop ? (width - 40) / 3 : width, label: 'Jumlah Bulan Aktif', value: '${_monthly.length}', icon: Icons.calendar_month, color: const Color(0xFF2ECC71), bgColor: const Color(0xFFE8F5E9)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  if (_monthly.isNotEmpty) ...[
                    _ChartCard(monthly: _monthly),
                    const SizedBox(height: 30),
                  ],
                  _IncomeTable(monthly: _monthly),
                ],
              ),
            ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pendapatan Bulanan', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFF2D3436))),
            SizedBox(height: 6),
            Text('Rincian pendapatan café per bulan berdasarkan data transaksi.', style: TextStyle(color: Color(0xFF636E72))),
          ],
        ),
        TextButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Kembali ke Dashboard'),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFE67E22)),
        ),
      ],
    );
  }
}

class _MonthlyIncome {
  final int tahun;
  final int bulan;
  final int jumlahTransaksi;
  final double totalPendapatan;

  _MonthlyIncome({required this.tahun, required this.bulan, required this.jumlahTransaksi, required this.totalPendapatan});

  factory _MonthlyIncome.fromJson(Map<String, dynamic> json) {
    return _MonthlyIncome(
      tahun: _toInt(json['tahun'] ?? json['year']),
      bulan: _toInt(json['bulan'] ?? json['month']),
      jumlahTransaksi: _toInt(json['jumlahTransaksi'] ?? json['jumlah_transaksi'] ?? json['transactions']),
      totalPendapatan: _toDouble(json['totalPendapatan'] ?? json['total_pendapatan'] ?? json['total']),
    );
  }

  String get label => '${_monthName(bulan)} $tahun';
  double get average => jumlahTransaksi <= 0 ? 0 : totalPendapatan / jumlahTransaksi;

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _monthName(int month) {
    const names = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return month >= 1 && month <= 12 ? names[month] : '-';
  }
}

class _SummaryCard extends StatelessWidget {
  final double width;
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _SummaryCard({required this.width, required this.label, required this.value, required this.icon, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 4))]),
        child: Row(
          children: [
            Container(width: 58, height: 58, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF636E72))),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: Color(0xFF2D3436)), overflow: TextOverflow.ellipsis),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final List<_MonthlyIncome> monthly;
  const _ChartCard({required this.monthly});

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final chronological = monthly.reversed.toList();
    final max = chronological.fold<double>(0, (m, i) => i.totalPendapatan > m ? i.totalPendapatan : m);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Grafik Pendapatan Bulanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2D3436))),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: chronological.map((item) {
                  final barHeight = max <= 0 ? 0.0 : (item.totalPendapatan / max) * 180;
                  return SizedBox(
                    width: 120,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(f.format(item.totalPendapatan), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF636E72))),
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 46,
                          height: barHeight < 12 ? 12 : barHeight,
                          decoration: BoxDecoration(color: const Color(0xFFE67E22), borderRadius: BorderRadius.circular(8)),
                        ),
                        const SizedBox(height: 10),
                        Text(item.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF636E72))),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeTable extends StatelessWidget {
  final List<_MonthlyIncome> monthly;
  const _IncomeTable({required this.monthly});

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 4))]),
      clipBehavior: Clip.antiAlias,
      child: monthly.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 70),
              child: Center(child: Text('Belum ada data pendapatan.', style: TextStyle(color: Color(0xFFB2BEC3)))),
            )
          : LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(const Color(0xFFF8F9FA)),
                    columns: const [
                      DataColumn(label: Text('No')),
                      DataColumn(label: Text('Bulan')),
                      DataColumn(label: Text('Jumlah Transaksi')),
                      DataColumn(label: Text('Total Pendapatan')),
                      DataColumn(label: Text('Rata-rata / Transaksi')),
                    ],
                    rows: monthly.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return DataRow(cells: [
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(item.label, style: const TextStyle(fontWeight: FontWeight.w700))),
                        DataCell(Text('${item.jumlahTransaksi} transaksi')),
                        DataCell(Text(f.format(item.totalPendapatan), style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFE67E22)))),
                        DataCell(Text(f.format(item.average))),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
    );
  }
}
