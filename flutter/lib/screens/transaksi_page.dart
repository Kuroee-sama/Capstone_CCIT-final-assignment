import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/menu_model.dart';
import '../services/api_service.dart';

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
  void initState() { super.initState(); _loadMenu(); }

  Future<void> _loadMenu() async {
    try {
      final m = await ApiService.getMenu();
      if (mounted) setState(() { _menuList = m; _isLoading = false; });
    } catch (_) { if (mounted) setState(() => _isLoading = false); }
  }

  void _add(MenuModel m) {
    setState(() {
      if (_cart.containsKey(m.menuId)) {
        if (_cart[m.menuId]!.qty < m.stok) _cart[m.menuId]!.qty++;
      } else {
        _cart[m.menuId] = _CartItem(menu: m, qty: 1);
      }
    });
  }

  void _remove(int id) {
    setState(() {
      if (_cart.containsKey(id)) {
        if (_cart[id]!.qty > 1) {
          _cart[id]!.qty--;
        } else {
          _cart.remove(id);
        }
      }
    });
  }

  double get _total => _cart.values.fold(0.0, (s, i) => s + i.menu.harga * i.qty);
  int get _qty => _cart.values.fold(0, (s, i) => s + i.qty);

  Future<void> _pay() async {
    if (_cart.isEmpty) return;
    setState(() => _isProcessing = true);
    try {
      final items = _cart.values.map((i) => {'menuId': i.menu.menuId, 'jumlah': i.qty}).toList();
      final r = await ApiService.createTransaksi(items: items);
      if (mounted) {
        setState(() { _cart.clear(); _isProcessing = false; });
        _loadMenu();
        _showReceipt(r.transaksiId, r.totalAmount);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
      }
    }
  }

  void _showReceipt(int id, double total) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 60, height: 60, decoration: const BoxDecoration(color: Color(0xFF2ECC71), shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 36)),
        const SizedBox(height: 16),
        const Text('Transaksi Sukses!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('ID: #$id', style: const TextStyle(color: Color(0xFF636E72))),
        Text(f.format(total), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFFE67E22))),
      ]),
      actions: [SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D3436), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
        child: const Text('SELESAI', style: TextStyle(fontWeight: FontWeight.w700)),
      ))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final filtered = _menuList.where((m) => m.namaItem.toLowerCase().contains(_search.toLowerCase())).toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Transaksi Baru', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D3436))), backgroundColor: Colors.white, elevation: 1, iconTheme: const IconThemeData(color: Color(0xFF2D3436))),
      body: _isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22)))
        : Column(children: [
          Container(color: Colors.white, padding: const EdgeInsets.all(12), child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(hintText: 'Cari menu...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE67E22))), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          )),
          Expanded(child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final m = filtered[i]; final cq = _cart[m.menuId]?.qty ?? 0;
              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: cq > 0 ? const Color(0xFFE67E22) : const Color(0xFFF1F2F6), width: cq > 0 ? 2 : 1)),
                child: InkWell(onTap: m.stok > 0 ? () => _add(m) : null, borderRadius: BorderRadius.circular(16), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m.namaItem, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(5)), child: Text(m.kategoriNama, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFE67E22)))),
                  const Spacer(),
                  Text('Stok: ${m.stok}', style: TextStyle(fontSize: 11, color: m.stok > 0 ? const Color(0xFF636E72) : Colors.red)),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Flexible(child: Text(f.format(m.harga), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
                    if (cq > 0) Row(mainAxisSize: MainAxisSize.min, children: [
                      _btn(Icons.remove, () => _remove(m.menuId), Colors.red),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Text('$cq', style: const TextStyle(fontWeight: FontWeight.w700))),
                      _btn(Icons.add, () => _add(m), const Color(0xFF2D3436)),
                    ]) else _btn(Icons.add, m.stok > 0 ? () => _add(m) : () {}, m.stok > 0 ? const Color(0xFF2D3436) : Colors.grey),
                  ]),
                ]))),
              );
            },
          )),
          if (_cart.isNotEmpty) Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -4))]),
            child: SafeArea(top: false, child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text('$_qty item', style: const TextStyle(fontSize: 13, color: Color(0xFF636E72))),
                Text(f.format(_total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFFE67E22))),
              ])),
              SizedBox(height: 50, child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _pay,
                icon: _isProcessing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.shopping_cart_checkout),
                label: const Text('BAYAR', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE67E22), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(horizontal: 28)),
              )),
            ])),
          ),
        ]),
    );
  }

  Widget _btn(IconData ic, VoidCallback tap, Color c) => GestureDetector(onTap: tap, child: Container(width: 28, height: 28, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8)), child: Icon(ic, color: Colors.white, size: 18)));
}
