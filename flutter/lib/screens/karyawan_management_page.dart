import 'package:flutter/material.dart';
import '../models/karyawan_model.dart';
import '../services/api_service.dart';

class KaryawanManagementPage extends StatefulWidget {
  const KaryawanManagementPage({super.key});

  @override
  State<KaryawanManagementPage> createState() => _KaryawanManagementPageState();
}

class _KaryawanManagementPageState extends State<KaryawanManagementPage> {
  List<KaryawanModel> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getKaryawan(size: 200);
      if (mounted) {
        setState(() {
          _items = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Future<void> _openForm([KaryawanModel? item]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _KaryawanFormDialog(item: item),
    );
    if (saved == true) _load();
  }

  Future<void> _delete(KaryawanModel item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Karyawan'),
        content: Text('Hapus akun ${item.username}? Data transaksi yang terkait dapat ikut terpengaruh sesuai aturan database.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE74C3C)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ApiService.deleteKaryawan(item.karyawanId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Karyawan berhasil dihapus')));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F4),
        foregroundColor: const Color(0xFF2D3436),
        title: const Text('Kelola Karyawan', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE67E22),
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Tambah'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22)))
          : RefreshIndicator(
              color: const Color(0xFFE67E22),
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
                children: [
                  const Text('Kelola Karyawan', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF2D3436))),
                  const SizedBox(height: 6),
                  const Text('Tambah, edit, dan hapus akun admin atau karyawan.', style: TextStyle(color: Color(0xFF636E72))),
                  const SizedBox(height: 20),
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Text(_error!, style: const TextStyle(color: Color(0xFFE74C3C))),
                    ),
                  LayoutBuilder(builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 820;
                    if (wide) return _KaryawanTable(items: _items, onEdit: _openForm, onDelete: _delete);
                    if (_items.isEmpty) return const _EmptyCard();
                    return Column(
                      children: _items.map((item) => _KaryawanMobileCard(item: item, onEdit: () => _openForm(item), onDelete: () => _delete(item))).toList(),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class _KaryawanTable extends StatelessWidget {
  final List<KaryawanModel> items;
  final void Function(KaryawanModel item) onEdit;
  final void Function(KaryawanModel item) onDelete;

  const _KaryawanTable({required this.items, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyCard();
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 15, offset: const Offset(0, 4))]),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFFAFAFA)),
          columns: const [
            DataColumn(label: Text('No')),
            DataColumn(label: Text('Username')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('No. Telepon')),
            DataColumn(label: Text('Umur')),
            DataColumn(label: Text('Aksi')),
          ],
          rows: [
            for (var i = 0; i < items.length; i++)
              DataRow(cells: [
                DataCell(Text('${i + 1}')),
                DataCell(Text(items[i].username, style: const TextStyle(fontWeight: FontWeight.w700))),
                DataCell(Text(items[i].email)),
                DataCell(_RoleChip(role: items[i].role)),
                DataCell(Text(items[i].noTelp ?? '-')),
                DataCell(Text(items[i].umur?.toString() ?? '-')),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(onPressed: () => onEdit(items[i]), icon: const Icon(Icons.edit, size: 16), label: const Text('Edit')),
                    TextButton.icon(onPressed: () => onDelete(items[i]), icon: const Icon(Icons.delete, size: 16), label: const Text('Hapus'), style: TextButton.styleFrom(foregroundColor: const Color(0xFFE74C3C))),
                  ],
                )),
              ]),
          ],
        ),
      ),
    );
  }
}

class _KaryawanMobileCard extends StatelessWidget {
  final KaryawanModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _KaryawanMobileCard({required this.item, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 15, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: item.isAdmin ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)), child: Icon(item.isAdmin ? Icons.admin_panel_settings : Icons.badge, color: item.isAdmin ? const Color(0xFF2ECC71) : const Color(0xFF3498DB))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.username, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(item.email, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF636E72)))])),
              _RoleChip(role: item.role),
            ],
          ),
          const SizedBox(height: 12),
          Text('Telepon: ${item.noTelp ?? '-'}', style: const TextStyle(color: Color(0xFF636E72))),
          Text('Umur: ${item.umur?.toString() ?? '-'}', style: const TextStyle(color: Color(0xFF636E72))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit, size: 16), label: const Text('Edit'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: onDelete, icon: const Icon(Icons.delete, size: 16), label: const Text('Hapus'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFE74C3C)))),
            ],
          ),
        ],
      ),
    );
  }
}

class _KaryawanFormDialog extends StatefulWidget {
  final KaryawanModel? item;
  const _KaryawanFormDialog({this.item});

  @override
  State<_KaryawanFormDialog> createState() => _KaryawanFormDialogState();
}

class _KaryawanFormDialogState extends State<_KaryawanFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _umurCtrl;
  late final TextEditingController _alamatCtrl;
  late final TextEditingController _tglLahirCtrl;
  late final TextEditingController _noTelpCtrl;
  late String _role;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _usernameCtrl = TextEditingController(text: item?.username ?? '');
    _emailCtrl = TextEditingController(text: item?.email ?? '');
    _passwordCtrl = TextEditingController();
    _umurCtrl = TextEditingController(text: item?.umur?.toString() ?? '');
    _alamatCtrl = TextEditingController(text: item?.alamat ?? '');
    _tglLahirCtrl = TextEditingController(text: item?.tglLahir ?? '');
    _noTelpCtrl = TextEditingController(text: item?.noTelp ?? '');
    _role = item?.role.toUpperCase() ?? 'KARYAWAN';
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _umurCtrl.dispose();
    _alamatCtrl.dispose();
    _tglLahirCtrl.dispose();
    _noTelpCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });

    final umur = _umurCtrl.text.trim().isEmpty ? null : int.tryParse(_umurCtrl.text.trim());
    try {
      if (_isEdit) {
        await ApiService.updateKaryawan(
          karyawanId: widget.item!.karyawanId,
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim().isEmpty ? null : _passwordCtrl.text,
          role: _role,
          umur: umur,
          alamat: _alamatCtrl.text,
          tglLahir: _tglLahirCtrl.text,
          noTelp: _noTelpCtrl.text,
        );
      } else {
        await ApiService.createKaryawan(
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          role: _role,
          umur: umur,
          alamat: _alamatCtrl.text,
          tglLahir: _tglLahirCtrl.text,
          noTelp: _noTelpCtrl.text,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final compact = maxWidth < 520;
    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 20 : 26),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isEdit ? 'Edit Karyawan' : 'Tambah Karyawan', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                if (_error != null)
                  Container(width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFECACA))), child: Text(_error!, style: const TextStyle(color: Color(0xFFE74C3C)))),
                Wrap(
                  runSpacing: 12,
                  spacing: 12,
                  children: [
                    _sized(compact, _field(_usernameCtrl, 'Username', required: true)),
                    _sized(compact, _field(_emailCtrl, 'Email', required: true, keyboardType: TextInputType.emailAddress)),
                    _sized(compact, _field(_passwordCtrl, _isEdit ? 'Password baru (opsional)' : 'Password', required: !_isEdit, obscure: true)),
                    _sized(compact, DropdownButtonFormField<String>(
                      value: _role,
                      decoration: _decoration('Role'),
                      items: const [DropdownMenuItem(value: 'KARYAWAN', child: Text('KARYAWAN')), DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN'))],
                      onChanged: (v) => setState(() => _role = v ?? 'KARYAWAN'),
                    )),
                    _sized(compact, _field(_umurCtrl, 'Umur', keyboardType: TextInputType.number)),
                    _sized(compact, _field(_tglLahirCtrl, 'Tanggal lahir (YYYY-MM-DD)')),
                    _sized(compact, _field(_noTelpCtrl, 'No. Telepon')),
                    SizedBox(width: double.infinity, child: _field(_alamatCtrl, 'Alamat', maxLines: 3)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: _saving ? null : () => Navigator.pop(context, false), child: const Text('Batal')),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _saving ? null : _submit,
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE67E22)),
                      child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sized(bool compact, Widget child) => SizedBox(width: compact ? double.infinity : 280, child: child);

  Widget _field(TextEditingController controller, String label, {bool required = false, bool obscure = false, int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _decoration(label),
      validator: (value) {
        final v = value?.trim() ?? '';
        if (required && v.isEmpty) return '$label wajib diisi';
        if (label.toLowerCase().contains('password') && v.isNotEmpty && v.length < 6) return 'Password minimal 6 karakter';
        return null;
      },
    );
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE67E22), width: 2)),
      );
}

class _RoleChip extends StatelessWidget {
  final String role;
  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role.toUpperCase() == 'ADMIN';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: isAdmin ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(999)),
      child: Text(role.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isAdmin ? const Color(0xFF2ECC71) : const Color(0xFF3498DB))),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: const Text('Belum ada data karyawan.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF636E72))),
    );
  }
}
