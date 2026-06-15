import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'login_page.dart';
import 'transaksi_page.dart';
import 'riwayat_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic> _summary = {};
  String _username = '';
  String _role = 'KARYAWAN';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiService.getDashboardSummary(),
        AuthService.getUsername(),
        AuthService.getRole(),
      ]);
      if (mounted) {
        setState(() {
          _summary = results[0] as Map<String, dynamic>;
          _username = results[1] as String;
          _role = results[2] as String;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _role.toUpperCase() == 'ADMIN';
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: 'Cafeín', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2D3436))),
              TextSpan(text: 'aja', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFFE67E22))),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isAdmin ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _role,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isAdmin ? const Color(0xFF2ECC71) : const Color(0xFF3498DB),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFF1416C)),
            onPressed: _logout,
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22)))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFFE67E22),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Header
                  Text(
                    isAdmin ? 'Dashboard Admin' : 'Dashboard Kasir',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF2D3436)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selamat datang, $_username!',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF636E72)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Stats Cards
                  if (isAdmin) ...[
                    _StatCard(
                      icon: Icons.monetization_on,
                      label: 'Total Pendapatan',
                      value: currencyFormat.format(_summary['totalPendapatan'] ?? 0),
                      color: const Color(0xFFE67E22),
                      bgColor: const Color(0xFFFFF3E0),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.receipt_long,
                          label: isAdmin ? 'Total Transaksi' : 'Transaksi Saya',
                          value: '${_summary[isAdmin ? 'totalTransaksi' : 'totalTransaksiSaya'] ?? 0}',
                          color: const Color(0xFF3498DB),
                          bgColor: const Color(0xFFE3F2FD),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.restaurant_menu,
                          label: 'Total Menu',
                          value: '${_summary['totalMenu'] ?? 0}',
                          color: const Color(0xFF2ECC71),
                          bgColor: const Color(0xFFE8F5E9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Menu Cards
                  _MenuCard(
                    icon: '🛒',
                    title: 'Transaksi Baru',
                    subtitle: 'Mulai pesanan baru',
                    borderColor: const Color(0xFFE67E22),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransaksiPage())).then((_) => _loadData()),
                  ),
                  const SizedBox(height: 16),
                  _MenuCard(
                    icon: '📜',
                    title: 'Riwayat Transaksi',
                    subtitle: isAdmin ? 'Lihat semua laporan penjualan' : 'Lihat riwayat transaksi Anda',
                    borderColor: const Color(0xFF3498DB),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatPage())),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2D3436)), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color borderColor;
  final VoidCallback onTap;

  const _MenuCard({required this.icon, required this.title, required this.subtitle, required this.borderColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border(top: BorderSide(color: borderColor, width: 4)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2D3436))),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF636E72))),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFB2BEC3)),
            ],
          ),
        ),
      ),
    );
  }
}
