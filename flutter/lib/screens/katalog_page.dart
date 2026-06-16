import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/kategori_model.dart';
import '../models/menu_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/menu_image.dart';
import 'dashboard_page.dart';
import 'login_page.dart';
import 'register_page.dart';

class KatalogPage extends StatefulWidget {
  const KatalogPage({super.key});

  @override
  State<KatalogPage> createState() => _KatalogPageState();
}

class _KatalogPageState extends State<KatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  List<MenuModel> _menus = [];
  List<KategoriModel> _kategori = [];
  String _selectedKategori = 'Semua';
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getMenu(),
        ApiService.getKategori(),
        AuthService.isLoggedIn(),
      ]);

      if (!mounted) return;
      setState(() {
        _menus = results[0] as List<MenuModel>;
        _kategori = results[1] as List<KategoriModel>;
        _isLoggedIn = results[2] as bool;
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

  List<MenuModel> get _filteredMenus {
    final keyword = _searchController.text.trim().toLowerCase();
    return _menus.where((menu) {
      final matchKeyword = keyword.isEmpty || menu.namaItem.toLowerCase().contains(keyword);
      final matchKategori = _selectedKategori == 'Semua' || menu.kategoriNama.toLowerCase() == _selectedKategori.toLowerCase();
      return matchKeyword && matchKategori;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Cafeín', style: TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.w800)),
              TextSpan(text: 'aja', style: TextStyle(color: Color(0xFFE67E22), fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        actions: [
          if (_isLoggedIn)
            TextButton.icon(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage())),
              icon: const Icon(Icons.dashboard_outlined, size: 18),
              label: const Text('Dashboard'),
            )
          else ...[
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
              child: const Text('Login'),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE67E22), foregroundColor: Colors.white),
                child: const Text('Daftar'),
              ),
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22)))
          : _error != null
              ? _KatalogError(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  color: const Color(0xFFE67E22),
                  onRefresh: _load,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns = width >= 1100 ? 3 : width >= 720 ? 2 : 1;
                      final filteredMenus = _filteredMenus;

                      return ListView(
                        padding: EdgeInsets.symmetric(horizontal: width < 700 ? 16 : 30, vertical: 24),
                        children: [
                          const _KatalogHeader(),
                          const SizedBox(height: 28),
                          _KatalogToolbar(
                            controller: _searchController,
                            kategori: _kategori,
                            selectedKategori: _selectedKategori,
                            onChangedSearch: (_) => setState(() {}),
                            onSelectedKategori: (value) => setState(() => _selectedKategori = value),
                          ),
                          const SizedBox(height: 28),
                          if (filteredMenus.isEmpty)
                            const _NoMenuState()
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredMenus.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                                mainAxisExtent: width < 700 ? 360 : 390,
                              ),
                              itemBuilder: (_, index) => _KatalogCard(menu: filteredMenus[index]),
                            ),
                        ],
                      );
                    },
                  ),
                ),
    );
  }
}

class _KatalogHeader extends StatelessWidget {
  const _KatalogHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Katalog Menu',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF1E1E2D)),
        ),
        SizedBox(height: 8),
        Text(
          "Selamat datang di Cafe'in aja — Jelajahi menu kami",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Color(0xFF7E8299)),
        ),
      ],
    );
  }
}

class _KatalogToolbar extends StatelessWidget {
  final TextEditingController controller;
  final List<KategoriModel> kategori;
  final String selectedKategori;
  final ValueChanged<String> onChangedSearch;
  final ValueChanged<String> onSelectedKategori;

  const _KatalogToolbar({
    required this.controller,
    required this.kategori,
    required this.selectedKategori,
    required this.onChangedSearch,
    required this.onSelectedKategori,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 700;

    final search = TextField(
      controller: controller,
      onChanged: onChangedSearch,
      decoration: InputDecoration(
        hintText: 'Cari menu favoritmu...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE67E22), width: 1.5)),
      ),
    );

    final filters = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterChipButton(label: 'Semua', selected: selectedKategori == 'Semua', onTap: () => onSelectedKategori('Semua')),
        ...kategori.map((k) => _FilterChipButton(
              label: k.namaKategori,
              selected: selectedKategori == k.namaKategori,
              onTap: () => onSelectedKategori(k.namaKategori),
            )),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: isMobile
          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [search, const SizedBox(height: 14), filters])
          : Row(children: [Expanded(child: search), const SizedBox(width: 18), Flexible(child: filters)]),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE67E22) : Colors.white,
          border: Border.all(color: selected ? const Color(0xFFE67E22) : const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF2D3436),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _KatalogCard extends StatelessWidget {
  final MenuModel menu;

  const _KatalogCard({required this.menu});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MenuImage(
            menu: menu,
            width: double.infinity,
            height: 180,
            borderRadius: BorderRadius.zero,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFFF4E5), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      menu.kategoriNama.toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFE67E22)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    menu.namaItem,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF181C32)),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      menu.mDescription?.trim().isNotEmpty == true ? menu.mDescription!.trim() : 'Menu lezat dari café kami.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, height: 1.45, color: Color(0xFF7E8299)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currencyFormat.format(menu.harga),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFE67E22)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoMenuState extends StatelessWidget {
  const _NoMenuState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: const Column(
        children: [
          Icon(Icons.restaurant_menu, size: 54, color: Color(0xFFE0E0E0)),
          SizedBox(height: 12),
          Text('Menu tidak ditemukan', style: TextStyle(color: Color(0xFF7E8299), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _KatalogError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _KatalogError({required this.message, required this.onRetry});

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
