import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'login_page.dart';
import 'menu_management_page.dart';
import 'pendapatan_page.dart';
import 'riwayat_page.dart';
import 'transaksi_page.dart';

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
    } catch (_) {
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

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page)).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _role.toUpperCase() == 'ADMIN';
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(67),
        child: _CafeNavBar(
          role: _role,
          isAdmin: isAdmin,
          onDashboard: () {},
          onTransaksi: () => _open(const TransaksiPage()),
          onMenu: isAdmin ? () => _open(const MenuManagementPage()) : null,
          onRiwayat: () => _open(const RiwayatPage()),
          onPendapatan: isAdmin ? () => _open(const PendapatanPage()) : null,
          onLogout: _logout,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22)))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFFE67E22),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final horizontalPadding = width < 700 ? 15.0 : 30.0;
                  final statColumns = width >= 900 ? 3 : width >= 620 ? 2 : 1;
                  final menuColumns = width >= 1200 ? 4 : width >= 900 ? 2 : 1;

                  final statCards = <Widget>[
                    if (isAdmin)
                      _StatCard(
                        icon: Icons.monetization_on,
                        label: 'Total Pendapatan',
                        value: currencyFormat.format(_summary['totalPendapatan'] ?? 0),
                        color: const Color(0xFFE67E22),
                        bgColor: const Color(0xFFFFF3E0),
                      ),
                    _StatCard(
                      icon: Icons.receipt_long,
                      label: isAdmin ? 'Total Transaksi' : 'Transaksi Saya',
                      value: '${_summary[isAdmin ? 'totalTransaksi' : 'totalTransaksiSaya'] ?? 0}',
                      color: const Color(0xFF3498DB),
                      bgColor: const Color(0xFFE3F2FD),
                    ),
                    _StatCard(
                      icon: Icons.restaurant_menu,
                      label: 'Total Menu',
                      value: '${_summary['totalMenu'] ?? 0}',
                      color: const Color(0xFF2ECC71),
                      bgColor: const Color(0xFFE8F5E9),
                    ),
                  ];

                  final menuCards = <Widget>[
                    _MenuCard(
                      icon: '🛒',
                      title: 'Transaksi Baru',
                      subtitle: 'Mulai pesanan baru.',
                      borderColor: const Color(0xFFE67E22),
                      iconBg: const Color(0xFFFFF3E0),
                      onTap: () => _open(const TransaksiPage()),
                    ),
                    if (isAdmin)
                      _MenuCard(
                        icon: '🍔',
                        title: 'Kelola Menu',
                        subtitle: 'Tambah, edit, hapus menu.',
                        borderColor: const Color(0xFF2ECC71),
                        iconBg: const Color(0xFFE8F5E9),
                        onTap: () => _open(const MenuManagementPage()),
                      ),
                    _MenuCard(
                      icon: '📜',
                      title: 'Riwayat Transaksi',
                      subtitle: isAdmin ? 'Lihat semua laporan penjualan.' : 'Lihat riwayat transaksi Anda.',
                      borderColor: const Color(0xFF3498DB),
                      iconBg: const Color(0xFFE3F2FD),
                      onTap: () => _open(const RiwayatPage()),
                    ),
                    if (isAdmin)
                      _MenuCard(
                        icon: '📊',
                        title: 'Pendapatan Bulanan',
                        subtitle: 'Rincian pendapatan per bulan.',
                        borderColor: const Color(0xFF9B59B6),
                        iconBg: const Color(0xFFF3E5F5),
                        onTap: () => _open(const PendapatanPage()),
                      ),
                  ];

                  return ListView(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30),
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        isAdmin ? 'Dashboard Admin' : 'Dashboard Kasir',
                        style: const TextStyle(
                          fontSize: 34,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3436),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'Selamat datang, '),
                            TextSpan(text: _username, style: const TextStyle(fontWeight: FontWeight.w700)),
                            TextSpan(text: isAdmin ? '. Kelola operasional café Anda di sini.' : '. Siap untuk melayani pelanggan hari ini!'),
                          ],
                        ),
                        style: const TextStyle(fontSize: 16, color: Color(0xFF636E72)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      _ResponsiveGrid(
                        columns: statColumns,
                        spacing: 20,
                        childAspectRatio: width >= 900 ? 4.0 : width >= 620 ? 2.7 : 3.0,
                        children: statCards,
                      ),
                      const SizedBox(height: 40),
                      _ResponsiveGrid(
                        columns: menuColumns,
                        spacing: 25,
                        childAspectRatio: width >= 1200 ? 3.0 : width >= 900 ? 2.8 : 2.3,
                        children: menuCards,
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}

class _CafeNavBar extends StatelessWidget {
  final String role;
  final bool isAdmin;
  final VoidCallback onDashboard;
  final VoidCallback onTransaksi;
  final VoidCallback? onMenu;
  final VoidCallback onRiwayat;
  final VoidCallback? onPendapatan;
  final VoidCallback onLogout;

  const _CafeNavBar({
    required this.role,
    required this.isAdmin,
    required this.onDashboard,
    required this.onTransaksi,
    required this.onMenu,
    required this.onRiwayat,
    required this.onPendapatan,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1.8,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            return Container(
              height: 67,
              padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 30),
              child: Row(
                children: [
                  _Brand(onTap: onDashboard),
                  const Spacer(),
                  if (!compact) ...[
                    _RoleBadge(role: role, isAdmin: isAdmin),
                    const SizedBox(width: 15),
                    _NavLink(icon: Icons.home, label: 'Dashboard', onTap: onDashboard),
                    _NavLink(icon: Icons.point_of_sale, label: 'Transaksi', onTap: onTransaksi),
                    if (isAdmin && onMenu != null) _NavLink(icon: Icons.restaurant_menu, label: 'Menu', onTap: onMenu!),
                    _NavLink(icon: Icons.history, label: 'Riwayat', onTap: onRiwayat),
                    if (isAdmin && onPendapatan != null) _NavLink(icon: Icons.bar_chart, label: 'Pendapatan', onTap: onPendapatan!),
                    const SizedBox(width: 10),
                    _LogoutButton(onTap: onLogout),
                  ] else ...[
                    _RoleBadge(role: role, isAdmin: isAdmin),
                    IconButton(
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout, color: Color(0xFFF1416C)),
                      tooltip: 'Keluar',
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  final VoidCallback onTap;
  const _Brand({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: 'Cafeín', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2D3436))),
              TextSpan(text: 'aja', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFFE67E22))),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  final bool isAdmin;
  const _RoleBadge({required this.role, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isAdmin ? const Color(0xFF2ECC71) : const Color(0xFF3498DB),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF636E72)),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF636E72))),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFFFF5F8), borderRadius: BorderRadius.circular(8)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout, size: 16, color: Color(0xFFF1416C)),
            SizedBox(width: 5),
            Text('Keluar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFF1416C))),
          ],
        ),
      ),
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  final int columns;
  final double spacing;
  final double childAspectRatio;
  final List<Widget> children;

  const _ResponsiveGrid({required this.columns, required this.spacing, required this.childAspectRatio, required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => children[index],
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
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF636E72))),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF2D3436)), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatefulWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color borderColor;
  final Color iconBg;
  final VoidCallback onTap;

  const _MenuCard({required this.icon, required this.title, required this.subtitle, required this.borderColor, required this.iconBg, required this.onTap});

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hovered ? -5 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border(top: BorderSide(color: widget.borderColor, width: 5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.08 : 0.03),
              blurRadius: _hovered ? 25 : 15,
              offset: Offset(0, _hovered ? 10 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Row(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(color: widget.iconBg, borderRadius: BorderRadius.circular(15)),
                    alignment: Alignment.center,
                    child: Text(widget.icon, style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2D3436))),
                        const SizedBox(height: 5),
                        Text(widget.subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF636E72))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
