import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/menu_model.dart';
import '../services/api_service.dart';
import '../widgets/menu_image.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});
  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _CartItem {
  final MenuModel menu;
  int qty;
  _CartItem({required this.menu, required this.qty});
}

class _TransaksiPageState extends State<TransaksiPage> {
  List<MenuModel> _menuList = [];
  final Map<int, _CartItem> _cart = {};
  bool _isLoading = true;
  bool _isProcessing = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);
    try {
      final menu = await ApiService.getMenu();
      if (!mounted) return;
      setState(() {
        _menuList = menu;
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

  void _add(MenuModel menu) {
    final existing = _cart[menu.menuId];
    final currentQty = existing?.qty ?? 0;
    final requestedQty = currentQty + 1;

    if (menu.stok <= 0 || requestedQty > menu.stok) {
      _showStockWarning(menu: menu, currentQty: currentQty, requestedQty: requestedQty);
      return;
    }

    setState(() {
      if (existing == null) {
        _cart[menu.menuId] = _CartItem(menu: menu, qty: 1);
      } else {
        existing.qty++;
      }
    });
  }

  void _showStockWarning({required MenuModel menu, required int currentQty, required int requestedQty}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.priority_high_rounded, color: Color(0xFFE67E22), size: 30),
            ),
            const SizedBox(height: 18),
            const Text('Stok Tidak Cukup', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF2D3436))),
            const SizedBox(height: 8),
            Text(
              'Pesanan ${menu.namaItem} tidak dapat ditambahkan karena jumlah melebihi stok yang tersedia.',
              style: const TextStyle(color: Color(0xFF636E72), height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8EF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD8A8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stok tersedia: ${menu.stok}', style: const TextStyle(color: Color(0xFFD35400), fontWeight: FontWeight.w600)),
                  Text('Jumlah di keranjang: $currentQty', style: const TextStyle(color: Color(0xFFD35400), fontWeight: FontWeight.w600)),
                  Text('Jumlah diminta: $requestedQty', style: const TextStyle(color: Color(0xFFD35400), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D3436),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Mengerti', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeOne(int menuId) {
    setState(() {
      final existing = _cart[menuId];
      if (existing == null) return;
      if (existing.qty > 1) {
        existing.qty--;
      } else {
        _cart.remove(menuId);
      }
    });
  }

  void _removeAll(int menuId) => setState(() => _cart.remove(menuId));
  void _clearCart() => setState(() => _cart.clear());

  double get _total => _cart.values.fold(0.0, (sum, item) => sum + item.menu.harga * item.qty);
  int get _qty => _cart.values.fold(0, (sum, item) => sum + item.qty);

  Future<void> _pay() async {
    if (_cart.isEmpty || _isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final items = _cart.values.map((item) => {'menuId': item.menu.menuId, 'jumlah': item.qty}).toList();
      final result = await ApiService.createTransaksi(items: items, bayar: _total);
      if (!mounted) return;
      setState(() {
        _cart.clear();
        _isProcessing = false;
      });
      await _loadMenu();
      if (mounted) _showReceipt(result.transaksiId, result.totalAmount);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  void _showReceipt(int id, double total) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(color: Color(0xFF2ECC71), shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Transaksi Sukses!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('ID: #$id', style: const TextStyle(color: Color(0xFF636E72))),
            Text(f.format(total), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFFE67E22))),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D3436),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('SELESAI', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _menuList.where((m) {
      final key = _search.toLowerCase();
      return m.namaItem.toLowerCase().contains(key) || m.kategoriNama.toLowerCase().contains(key);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Transaksi Baru', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D3436))),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF2D3436)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22)))
          : LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 900;
                return RefreshIndicator(
                  onRefresh: _loadMenu,
                  color: const Color(0xFFE67E22),
                  child: isDesktop
                      ? _DesktopTransaksiLayout(
                          filtered: filtered,
                          cart: _cart,
                          search: _search,
                          isProcessing: _isProcessing,
                          total: _total,
                          qty: _qty,
                          onSearch: (v) => setState(() => _search = v),
                          onAdd: _add,
                          onRemoveOne: _removeOne,
                          onRemoveAll: _removeAll,
                          onClear: _clearCart,
                          onPay: _pay,
                        )
                      : _MobileTransaksiLayout(
                          filtered: filtered,
                          cart: _cart,
                          search: _search,
                          isProcessing: _isProcessing,
                          total: _total,
                          qty: _qty,
                          onSearch: (v) => setState(() => _search = v),
                          onAdd: _add,
                          onRemoveOne: _removeOne,
                          onRemoveAll: _removeAll,
                          onClear: _clearCart,
                          onPay: _pay,
                        ),
                );
              },
            ),
    );
  }
}

class _DesktopTransaksiLayout extends StatelessWidget {
  final List<MenuModel> filtered;
  final Map<int, _CartItem> cart;
  final String search;
  final bool isProcessing;
  final double total;
  final int qty;
  final ValueChanged<String> onSearch;
  final ValueChanged<MenuModel> onAdd;
  final ValueChanged<int> onRemoveOne;
  final ValueChanged<int> onRemoveAll;
  final VoidCallback onClear;
  final VoidCallback onPay;

  const _DesktopTransaksiLayout({
    required this.filtered,
    required this.cart,
    required this.search,
    required this.isProcessing,
    required this.total,
    required this.qty,
    required this.onSearch,
    required this.onAdd,
    required this.onRemoveOne,
    required this.onRemoveAll,
    required this.onClear,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(30),
      children: [
        _PageHeader(
          title: 'Panel Transaksi',
          subtitle: 'Kelola pesanan pelanggan secara langsung',
          trailing: TextButton.icon(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Kembali ke Dashboard'),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFE67E22)),
          ),
        ),
        const SizedBox(height: 25),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _MenuPanel(
                filtered: filtered,
                cart: cart,
                search: search,
                onSearch: onSearch,
                onAdd: onAdd,
                onRemoveOne: onRemoveOne,
                onRemoveAll: onRemoveAll,
                compact: false,
              ),
            ),
            const SizedBox(width: 30),
            SizedBox(
              width: 420,
              child: _CheckoutPanel(
                cart: cart,
                isProcessing: isProcessing,
                total: total,
                qty: qty,
                onAdd: onAdd,
                onRemoveOne: onRemoveOne,
                onRemoveAll: onRemoveAll,
                onClear: onClear,
                onPay: onPay,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MobileTransaksiLayout extends StatelessWidget {
  final List<MenuModel> filtered;
  final Map<int, _CartItem> cart;
  final String search;
  final bool isProcessing;
  final double total;
  final int qty;
  final ValueChanged<String> onSearch;
  final ValueChanged<MenuModel> onAdd;
  final ValueChanged<int> onRemoveOne;
  final ValueChanged<int> onRemoveAll;
  final VoidCallback onClear;
  final VoidCallback onPay;

  const _MobileTransaksiLayout({
    required this.filtered,
    required this.cart,
    required this.search,
    required this.isProcessing,
    required this.total,
    required this.qty,
    required this.onSearch,
    required this.onAdd,
    required this.onRemoveOne,
    required this.onRemoveAll,
    required this.onClear,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _SearchBox(value: search, onChanged: onSearch),
              const SizedBox(height: 16),
              _MenuGrid(filtered: filtered, cart: cart, onAdd: onAdd, onRemoveOne: onRemoveOne, onRemoveAll: onRemoveAll, compact: true),
            ],
          ),
        ),
        if (cart.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -4))]),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('$qty item di keranjang', style: const TextStyle(fontSize: 13, color: Color(0xFF636E72)))),
                      TextButton.icon(
                        onPressed: isProcessing ? null : onClear,
                        icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                        label: const Text('Bersihkan'),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFFE74C3C), visualDensity: VisualDensity.compact),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          f.format(total),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFFE67E22)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: isProcessing ? null : onPay,
                          icon: isProcessing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.shopping_cart_checkout),
                          label: const Text('BAYAR', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE67E22),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _PageHeader({required this.title, required this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF2D3436))),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: Color(0xFF636E72))),
          ],
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _MenuPanel extends StatelessWidget {
  final List<MenuModel> filtered;
  final Map<int, _CartItem> cart;
  final String search;
  final ValueChanged<String> onSearch;
  final ValueChanged<MenuModel> onAdd;
  final ValueChanged<int> onRemoveOne;
  final ValueChanged<int> onRemoveAll;
  final bool compact;

  const _MenuPanel({required this.filtered, required this.cart, required this.search, required this.onSearch, required this.onAdd, required this.onRemoveOne, required this.onRemoveAll, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            children: [
              const Text('Daftar Menu Café', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2D3436))),
              SizedBox(width: 280, child: _SearchBox(value: search, onChanged: onSearch)),
            ],
          ),
          const SizedBox(height: 20),
          _MenuGrid(filtered: filtered, cart: cart, onAdd: onAdd, onRemoveOne: onRemoveOne, onRemoveAll: onRemoveAll, compact: compact),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SearchBox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Cari makanan/minuman...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDFE6E9))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDFE6E9))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE67E22))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  final List<MenuModel> filtered;
  final Map<int, _CartItem> cart;
  final ValueChanged<MenuModel> onAdd;
  final ValueChanged<int> onRemoveOne;
  final ValueChanged<int> onRemoveAll;
  final bool compact;

  const _MenuGrid({required this.filtered, required this.cart, required this.onAdd, required this.onRemoveOne, required this.onRemoveAll, required this.compact});

  @override
  Widget build(BuildContext context) {
    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: Text('Menu tidak ditemukan.', style: TextStyle(color: Color(0xFFB2BEC3)))),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: compact ? 176 : 220,
        mainAxisExtent: compact ? 238 : 226,
        crossAxisSpacing: compact ? 12 : 15,
        mainAxisSpacing: compact ? 12 : 15,
      ),
      itemCount: filtered.length,
      itemBuilder: (_, index) {
        final menu = filtered[index];
        final qty = cart[menu.menuId]?.qty ?? 0;
        return _MenuCard(
          menu: menu,
          qty: qty,
          compact: compact,
          onAdd: () => onAdd(menu),
          onRemove: () => onRemoveOne(menu.menuId),
          onRemoveAll: () => onRemoveAll(menu.menuId),
        );
      },
    );
  }
}

class _MenuCard extends StatelessWidget {
  final MenuModel menu;
  final int qty;
  final bool compact;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onRemoveAll;

  const _MenuCard({required this.menu, required this.qty, required this.compact, required this.onAdd, required this.onRemove, required this.onRemoveAll});

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final isOut = menu.stok <= 0;
    final isMax = qty >= menu.stok && menu.stok > 0;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.all(compact ? 10 : 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: qty > 0 ? const Color(0xFFE67E22) : const Color(0xFFF1F2F6), width: qty > 0 ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  MenuImage(menu: menu, width: double.infinity, height: compact ? 58 : 66, borderRadius: BorderRadius.circular(10)),
                  if (qty > 0)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: _ClearItemChip(onTap: onRemoveAll),
                    ),
                ],
              ),
              SizedBox(height: compact ? 8 : 10),
              Text(
                menu.namaItem,
                style: TextStyle(fontSize: compact ? 14 : 15, fontWeight: FontWeight.w700, color: const Color(0xFF2D3436)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: compact ? 4 : 5),
              _CategoryBadge(text: menu.kategoriNama),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Stok: ${menu.stok}',
                      style: TextStyle(fontSize: compact ? 11 : 12, color: isOut ? const Color(0xFFC0392B) : const Color(0xFF636E72)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (qty > 0) _QtyBadge(qty: qty),
                ],
              ),
              SizedBox(height: compact ? 6 : 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      f.format(menu.harga),
                      style: TextStyle(fontSize: compact ? 13 : 14, fontWeight: FontWeight.w800, color: const Color(0xFF2D3436)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (qty > 0) ...[
                    _SquareButton(icon: Icons.remove, onTap: onRemove, color: const Color(0xFFE74C3C), size: compact ? 28 : 30),
                    SizedBox(width: compact ? 4 : 6),
                  ],
                  _SquareButton(icon: Icons.add, onTap: onAdd, color: isOut || isMax ? const Color(0xFFB2BEC3) : const Color(0xFF2D3436), size: compact ? 30 : 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClearItemChip extends StatelessWidget {
  final VoidCallback onTap;
  const _ClearItemChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE74C3C),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: const SizedBox(
          width: 26,
          height: 26,
          child: Icon(Icons.close_rounded, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String text;
  const _CategoryBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(5)),
      child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFE67E22))),
    );
  }
}

class _QtyBadge extends StatelessWidget {
  final int qty;
  const _QtyBadge({required this.qty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFFE67E22), borderRadius: BorderRadius.circular(999)),
      child: Text('$qty', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

class _SquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;

  const _SquareButton({required this.icon, required this.onTap, required this.color, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.white, size: size <= 28 ? 16 : 18),
      ),
    );
  }
}

class _CheckoutPanel extends StatelessWidget {
  final Map<int, _CartItem> cart;
  final bool isProcessing;
  final double total;
  final int qty;
  final ValueChanged<MenuModel> onAdd;
  final ValueChanged<int> onRemoveOne;
  final ValueChanged<int> onRemoveAll;
  final VoidCallback onClear;
  final VoidCallback onPay;

  const _CheckoutPanel({required this.cart, required this.isProcessing, required this.total, required this.qty, required this.onAdd, required this.onRemoveOne, required this.onRemoveAll, required this.onClear, required this.onPay});

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Keranjang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2D3436))),
              if (cart.isNotEmpty) TextButton(onPressed: onClear, child: const Text('Kosongkan', style: TextStyle(color: Color(0xFFFF7675), fontWeight: FontWeight.w700))),
            ],
          ),
          const Divider(height: 26, color: Color(0xFFF1F2F6)),
          if (cart.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Center(child: Text('Keranjang masih kosong', style: TextStyle(color: Color(0xFFB2BEC3)))),
            )
          else
            ...cart.values.map((item) => _CartRow(item: item, onAdd: () => onAdd(item.menu), onRemoveOne: () => onRemoveOne(item.menu.menuId), onRemoveAll: () => onRemoveAll(item.menu.menuId))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                _TotalRow(label: 'Total item', value: '$qty'),
                const SizedBox(height: 10),
                const Divider(color: Color(0xFFDFE6E9)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Bayar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF2D3436))),
                    Flexible(child: Text(f.format(total), textAlign: TextAlign.end, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFFE67E22)))),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: cart.isEmpty || isProcessing ? null : onPay,
                    icon: isProcessing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.payment),
                    label: const Text('PROSES PEMBAYARAN', style: TextStyle(fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE67E22), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  final _CartItem item;
  final VoidCallback onAdd;
  final VoidCallback onRemoveOne;
  final VoidCallback onRemoveAll;

  const _CartRow({required this.item, required this.onAdd, required this.onRemoveOne, required this.onRemoveAll});

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final subtotal = item.menu.harga * item.qty;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFF1F2F6))),
      child: Row(
        children: [
          MenuImage(menu: item.menu, width: 50, height: 50, borderRadius: BorderRadius.circular(8)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.menu.namaItem, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(f.format(item.menu.harga), style: const TextStyle(fontSize: 12, color: Color(0xFF636E72))),
                const SizedBox(height: 7),
                Row(
                  children: [
                    _MiniQtyButton(label: '-', onTap: onRemoveOne),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.w800))),
                    _MiniQtyButton(label: '+', onTap: onAdd),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(onPressed: onRemoveAll, icon: const Icon(Icons.close, size: 18), color: const Color(0xFFE74C3C), visualDensity: VisualDensity.compact),
              Text(f.format(subtotal), style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniQtyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MiniQtyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: const Color(0xFF2D3436), borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  const _TotalRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Color(0xFF636E72))), Text(value, style: const TextStyle(fontWeight: FontWeight.w700))]);
  }
}
