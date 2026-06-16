import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/kategori_model.dart';
import '../models/menu_model.dart';
import '../models/picked_image_file.dart';
import '../services/api_service.dart';
import '../services/menu_image_picker.dart';
import '../widgets/menu_image.dart';
import '../widgets/app_notifications.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({super.key});

  @override
  State<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends State<MenuManagementPage> {
  List<KategoriModel> _kategori = [];
  List<MenuModel> _menu = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final result = await Future.wait([
        ApiService.getKategori(),
        ApiService.getMenu(),
      ]);
      if (!mounted) return;
      setState(() {
        _kategori = result[0] as List<KategoriModel>;
        _menu = result[1] as List<MenuModel>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e);
    }
  }

  void _showError(Object e) => AppNotifier.error(context, e);

  Future<void> _confirmDelete(String title, Future<void> Function() action, String successMessage) async {
    final ok = await AppNotifier.confirm(
      context,
      title: 'Konfirmasi Hapus',
      message: title,
      confirmText: 'Hapus',
      danger: true,
    );
    if (!ok) return;
    try {
      await action();
      await _load();
      if (!mounted) return;
      AppNotifier.success(context, successMessage);
    } catch (e) {
      _showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Kelola Menu & Kategori', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D3436))),
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
                  _Header(
                    onAddKategori: () => _openKategoriDialog(),
                    onAddMenu: () => _openMenuDialog(),
                  ),
                  const SizedBox(height: 30),
                  _SectionTitle(icon: Icons.local_offer, title: 'Daftar Kategori'),
                  const SizedBox(height: 14),
                  _KategoriTable(
                    kategori: _kategori,
                    onEdit: (k) => _openKategoriDialog(kategori: k),
                    onDelete: (k) => _confirmDelete('Hapus kategori "${k.namaKategori}"? Menu yang terhubung dapat kehilangan kategori.', () => ApiService.deleteKategori(k.kategoriId), 'Kategori berhasil dihapus.'),
                  ),
                  const SizedBox(height: 34),
                  _SectionTitle(icon: Icons.restaurant_menu, title: 'Daftar Menu'),
                  const SizedBox(height: 14),
                  _MenuTable(
                    menu: _menu,
                    onEdit: (m) => _openMenuDialog(menu: m),
                    onDelete: (m) => _confirmDelete('Hapus menu "${m.namaItem}"? Tindakan ini tidak dapat dibatalkan.', () => ApiService.deleteMenu(m.menuId), 'Menu berhasil dihapus.'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _openKategoriDialog({KategoriModel? kategori}) async {
    final nama = TextEditingController(text: kategori?.namaKategori ?? '');
    final deskripsi = TextEditingController(text: kategori?.kDescription ?? '');
    final isEdit = kategori != null;

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Input(label: 'Nama Kategori', controller: nama),
              const SizedBox(height: 14),
              _Input(label: 'Deskripsi', controller: deskripsi, maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final namaValue = nama.text.trim();
              final deskripsiValue = deskripsi.text.trim();
              if (namaValue.isEmpty) {
                AppNotifier.warning(context, 'Nama kategori wajib diisi.', title: 'Data belum lengkap');
                return;
              }
              if (namaValue.length < 5) {
                AppNotifier.warning(context, 'Nama kategori minimal 5 karakter.', title: 'Data belum valid');
                return;
              }
              if (deskripsiValue.isEmpty) {
                AppNotifier.warning(context, 'Deskripsi kategori wajib diisi.', title: 'Data belum lengkap');
                return;
              }
              if (deskripsiValue.length < 15) {
                AppNotifier.warning(context, 'Deskripsi kategori minimal 15 karakter.', title: 'Data belum valid');
                return;
              }
              try {
                if (isEdit) {
                  await ApiService.updateKategori(kategoriId: kategori.kategoriId, namaKategori: namaValue, deskripsi: deskripsiValue);
                } else {
                  await ApiService.createKategori(namaKategori: namaValue, deskripsi: deskripsiValue);
                }
                if (context.mounted) Navigator.pop(context, true);
              } catch (e) {
                if (context.mounted) _showError(e);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), foregroundColor: Colors.white),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (saved == true) {
      await _load();
      if (!mounted) return;
      AppNotifier.success(context, isEdit ? 'Kategori berhasil diperbarui.' : 'Kategori berhasil ditambahkan.');
    }
  }

  Future<void> _openMenuDialog({MenuModel? menu}) async {
    if (_kategori.isEmpty) {
      _showError('Tambahkan kategori terlebih dahulu sebelum menambah menu.');
      return;
    }

    final nama = TextEditingController(text: menu?.namaItem ?? '');
    final harga = TextEditingController(text: menu == null ? '' : menu.harga.toStringAsFixed(0));
    final stok = TextEditingController(text: menu == null ? '' : '${menu.stok}');
    final deskripsi = TextEditingController(text: menu?.mDescription ?? '');
    PickedImageFile? selectedImage;
    int selectedKategori = menu?.kategoriId ?? menu?.kategori?.kategoriId ?? _kategori.first.kategoriId;
    if (!_kategori.any((k) => k.kategoriId == selectedKategori)) {
      selectedKategori = _kategori.first.kategoriId;
    }
    final isEdit = menu != null;

    final saved = await showDialog<bool>(
      context: context,
      useSafeArea: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          final screenSize = MediaQuery.sizeOf(context);
          final isMobile = screenSize.width < 600;
          final dialogWidth = isMobile ? screenSize.width - 32 : 520.0;
          final dialogMaxHeight = screenSize.height * 0.88;

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: const Color(0xFFFFEFE6),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: dialogMaxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(isMobile ? 18 : 24, isMobile ? 18 : 24, isMobile ? 18 : 24, 8),
                    child: Text(
                      isEdit ? 'Edit Menu' : 'Tambah Menu',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF2D3436)),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(isMobile ? 18 : 24, 8, isMobile ? 18 : 24, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _Input(label: 'Nama Item', controller: nama),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<int>(
                            initialValue: selectedKategori,
                            isExpanded: true,
                            menuMaxHeight: 280,
                            decoration: _inputDecoration('Kategori'),
                            items: _kategori.map((k) => DropdownMenuItem(value: k.kategoriId, child: Text(k.namaKategori, overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (value) => setDialogState(() => selectedKategori = value ?? selectedKategori),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(child: _Input(label: 'Harga', controller: harga, keyboardType: TextInputType.number)),
                              const SizedBox(width: 12),
                              Expanded(child: _Input(label: 'Stok', controller: stok, keyboardType: TextInputType.number)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _Input(label: 'Deskripsi', controller: deskripsi, maxLines: 3),
                          const SizedBox(height: 14),
                          _MenuImagePickerField(
                            currentMenu: menu,
                            selectedImage: selectedImage,
                            onPick: () async {
                              try {
                                final picked = await pickMenuImage();
                                if (picked != null) {
                                  setDialogState(() => selectedImage = picked);
                                }
                              } catch (e) {
                                if (context.mounted) _showError(e);
                              }
                            },
                            onClear: () => setDialogState(() => selectedImage = null),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(isMobile ? 18 : 24, 8, isMobile ? 18 : 24, isMobile ? 18 : 22),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final namaValue = nama.text.trim();
                            final deskripsiValue = deskripsi.text.trim();
                            final parsedHarga = double.tryParse(harga.text.replaceAll('.', '').replaceAll(',', '.'));
                            final parsedStok = int.tryParse(stok.text);
                            if (namaValue.isEmpty) {
                              AppNotifier.warning(context, 'Nama item wajib diisi.', title: 'Data belum lengkap');
                              return;
                            }
                            if (namaValue.length < 5) {
                              AppNotifier.warning(context, 'Nama item minimal 5 karakter.', title: 'Data belum valid');
                              return;
                            }
                            if (parsedHarga == null) {
                              AppNotifier.warning(context, 'Harga wajib diisi dengan angka yang valid.', title: 'Data belum lengkap');
                              return;
                            }
                            if (parsedHarga < 0) {
                              AppNotifier.warning(context, 'Harga tidak boleh bernilai negatif.', title: 'Data belum valid');
                              return;
                            }
                            if (parsedStok == null) {
                              AppNotifier.warning(context, 'Stok wajib diisi dengan bilangan bulat.', title: 'Data belum lengkap');
                              return;
                            }
                            if (parsedStok < 0) {
                              AppNotifier.warning(context, 'Stok tidak boleh bernilai negatif.', title: 'Data belum valid');
                              return;
                            }
                            if (deskripsiValue.isEmpty) {
                              AppNotifier.warning(context, 'Deskripsi menu wajib diisi.', title: 'Data belum lengkap');
                              return;
                            }
                            if (deskripsiValue.length < 15) {
                              AppNotifier.warning(context, 'Deskripsi menu minimal 15 karakter.', title: 'Data belum valid');
                              return;
                            }
                            if (!isEdit && selectedImage == null) {
                              AppNotifier.warning(context, 'Gambar menu wajib dipilih saat menambah menu baru.', title: 'Data belum lengkap');
                              return;
                            }
                            try {
                              if (isEdit) {
                                await ApiService.updateMenuWithImage(
                                  menuId: menu.menuId,
                                  namaItem: namaValue,
                                  harga: parsedHarga,
                                  stok: parsedStok,
                                  kategoriId: selectedKategori,
                                  deskripsi: deskripsiValue,
                                  image: selectedImage,
                                );
                              } else {
                                await ApiService.createMenuWithImage(
                                  namaItem: namaValue,
                                  harga: parsedHarga,
                                  stok: parsedStok,
                                  kategoriId: selectedKategori,
                                  deskripsi: deskripsiValue,
                                  image: selectedImage,
                                );
                              }
                              if (context.mounted) Navigator.pop(context, true);
                            } catch (e) {
                              if (context.mounted) _showError(e);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE67E22),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (saved == true) {
      await _load();
      if (!mounted) return;
      AppNotifier.success(context, isEdit ? 'Menu berhasil diperbarui.' : 'Menu berhasil ditambahkan.');
    }
  }
}


class _MenuImagePickerField extends StatelessWidget {
  final MenuModel? currentMenu;
  final PickedImageFile? selectedImage;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _MenuImagePickerField({
    required this.currentMenu,
    required this.selectedImage,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasCurrentImage = (currentMenu?.gambar ?? '').trim().isNotEmpty;
    final hasSelectedImage = selectedImage != null;
    final fileLabel = hasSelectedImage
        ? selectedImage!.name
        : hasCurrentImage
            ? currentMenu!.gambar!
            : 'Belum ada gambar dipilih';
    final helperText = hasSelectedImage
        ? 'Ukuran: ${selectedImage!.sizeInMb.toStringAsFixed(2)} MB'
        : 'Format: JPG, PNG, WEBP, atau GIF. Maksimal 5 MB.';
    final buttonText = hasSelectedImage || hasCurrentImage ? 'Ganti Gambar' : 'Pilih Gambar';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 330;
        final preview = _ImagePreview(
          currentMenu: currentMenu,
          selectedImage: selectedImage,
          size: isNarrow ? 64 : 74,
        );

        final info = Column(
          crossAxisAlignment: isNarrow ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
          children: [
            Text(
              fileLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: isNarrow ? TextAlign.center : TextAlign.start,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2D3436)),
            ),
            const SizedBox(height: 5),
            Text(
              helperText,
              textAlign: isNarrow ? TextAlign.center : TextAlign.start,
              style: const TextStyle(fontSize: 11, color: Color(0xFF636E72), height: 1.25),
            ),
            const SizedBox(height: 10),
            isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PickImageButton(text: buttonText, onPick: onPick),
                      if (hasSelectedImage) ...[
                        const SizedBox(height: 6),
                        _ClearImageButton(onClear: onClear),
                      ],
                    ],
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PickImageButton(text: buttonText, onPick: onPick),
                      if (hasSelectedImage) _ClearImageButton(onClear: onClear),
                    ],
                  ),
          ],
        );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isNarrow ? 12 : 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gambar Menu',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF636E72)),
              ),
              const SizedBox(height: 12),
              if (isNarrow) ...[
                Center(child: preview),
                const SizedBox(height: 12),
                info,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    preview,
                    const SizedBox(width: 14),
                    Expanded(child: info),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PickImageButton extends StatelessWidget {
  final String text;
  final VoidCallback onPick;

  const _PickImageButton({required this.text, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPick,
      icon: const Icon(Icons.upload_file, size: 17),
      label: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFE67E22),
        side: const BorderSide(color: Color(0xFFE67E22)),
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _ClearImageButton extends StatelessWidget {
  final VoidCallback onClear;

  const _ClearImageButton({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onClear,
      icon: const Icon(Icons.close, size: 17),
      label: const Text('Batal Pilih', maxLines: 1, overflow: TextOverflow.ellipsis),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFE74C3C),
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final MenuModel? currentMenu;
  final PickedImageFile? selectedImage;
  final double size;

  const _ImagePreview({required this.currentMenu, required this.selectedImage, this.size = 74});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    if (selectedImage != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.memory(
          selectedImage!.bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    if ((currentMenu?.gambar ?? '').trim().isNotEmpty && currentMenu != null) {
      return MenuImage(menu: currentMenu!, width: size, height: size, borderRadius: borderRadius);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: borderRadius),
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: const Color(0xFFE67E22), size: size * 0.42),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onAddKategori;
  final VoidCallback onAddMenu;

  const _Header({required this.onAddKategori, required this.onAddMenu});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 15,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kelola Menu & Kategori', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF2D3436))),
            SizedBox(height: 5),
            Text('Tambah, edit, atau hapus menu dan kategori café', style: TextStyle(color: Color(0xFF636E72))),
          ],
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _ActionButton(label: 'Tambah Kategori', icon: Icons.local_offer, color: const Color(0xFF6C5CE7), onTap: onAddKategori),
            _ActionButton(label: 'Tambah Menu', icon: Icons.add, color: const Color(0xFFE67E22), onTap: onAddMenu),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F2F6), width: 2))),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6C5CE7), size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2D3436))),
        ],
      ),
    );
  }
}

class _KategoriTable extends StatelessWidget {
  final List<KategoriModel> kategori;
  final ValueChanged<KategoriModel> onEdit;
  final ValueChanged<KategoriModel> onDelete;

  const _KategoriTable({required this.kategori, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (kategori.isEmpty) {
      return const _EmptyBox(icon: Icons.local_offer, text: 'Belum ada kategori. Klik "Tambah Kategori" untuk mulai.');
    }
    return _TableBox(
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
        columns: const [
          DataColumn(label: Text('No')),
          DataColumn(label: Text('Nama Kategori')),
          DataColumn(label: Text('Deskripsi')),
          DataColumn(label: Text('Aksi')),
        ],
        rows: kategori.asMap().entries.map((entry) {
          final index = entry.key;
          final k = entry.value;
          return DataRow(cells: [
            DataCell(Text('${index + 1}')),
            DataCell(Text(k.namaKategori, style: const TextStyle(fontWeight: FontWeight.w700))),
            DataCell(Text((k.kDescription == null || k.kDescription!.isEmpty) ? '-' : k.kDescription!)),
            DataCell(_RowActions(onEdit: () => onEdit(k), onDelete: () => onDelete(k))),
          ]);
        }).toList(),
      ),
    );
  }
}

class _MenuTable extends StatelessWidget {
  final List<MenuModel> menu;
  final ValueChanged<MenuModel> onEdit;
  final ValueChanged<MenuModel> onDelete;

  const _MenuTable({required this.menu, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    if (menu.isEmpty) {
      return const _EmptyBox(icon: Icons.restaurant_menu, text: 'Belum ada menu. Klik "Tambah Menu" untuk mulai.');
    }
    return _TableBox(
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
        columns: const [
          DataColumn(label: Text('No')),
          DataColumn(label: Text('Gambar')),
          DataColumn(label: Text('Nama Item')),
          DataColumn(label: Text('Kategori')),
          DataColumn(label: Text('Harga')),
          DataColumn(label: Text('Stok')),
          DataColumn(label: Text('Deskripsi')),
          DataColumn(label: Text('Aksi')),
        ],
        rows: menu.asMap().entries.map((entry) {
          final index = entry.key;
          final m = entry.value;
          return DataRow(cells: [
            DataCell(Text('${index + 1}')),
            DataCell(MenuImage(menu: m, width: 55, height: 55, borderRadius: BorderRadius.circular(10))),
            DataCell(Text(m.namaItem, style: const TextStyle(fontWeight: FontWeight.w700))),
            DataCell(_KategoriBadge(text: m.kategoriNama)),
            DataCell(Text(f.format(m.harga), style: const TextStyle(fontWeight: FontWeight.w700))),
            DataCell(_StockPill(stok: m.stok)),
            DataCell(SizedBox(width: 210, child: Text((m.mDescription == null || m.mDescription!.isEmpty) ? '-' : m.mDescription!, overflow: TextOverflow.ellipsis))),
            DataCell(_RowActions(onEdit: () => onEdit(m), onDelete: () => onDelete(m))),
          ]);
        }).toList(),
      ),
    );
  }
}

class _TableBox extends StatelessWidget {
  final Widget child;
  const _TableBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 4))],
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyBox({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Icon(icon, size: 48, color: const Color(0xFFB2BEC3)),
          const SizedBox(height: 15),
          Text(text, style: const TextStyle(color: Color(0xFFB2BEC3))),
        ],
      ),
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(10)),
      alignment: Alignment.center,
      child: const Text('🍽️', style: TextStyle(fontSize: 24)),
    );
  }
}

class _KategoriBadge extends StatelessWidget {
  final String text;
  const _KategoriBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(8)),
      child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFE67E22))),
    );
  }
}

class _StockPill extends StatelessWidget {
  final int stok;
  const _StockPill({required this.stok});

  @override
  Widget build(BuildContext context) {
    final bool out = stok <= 0;
    final bool low = stok > 0 && stok <= 10;
    final color = out ? const Color(0xFFC0392B) : low ? const Color(0xFFB7791F) : const Color(0xFF1E8449);
    final bg = out ? const Color(0xFFFFE8E8) : low ? const Color(0xFFFFF4DE) : const Color(0xFFEAFaf1);
    return Container(
      constraints: const BoxConstraints(minWidth: 54),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      alignment: Alignment.center,
      child: Text('$stok', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
    );
  }
}

class _RowActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _RowActions({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit, size: 15),
          label: const Text('Edit'),
          style: TextButton.styleFrom(backgroundColor: const Color(0xFFE3F2FD), foregroundColor: const Color(0xFF2196F3)),
        ),
        const SizedBox(width: 6),
        TextButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete, size: 15),
          label: const Text('Hapus'),
          style: TextButton.styleFrom(backgroundColor: const Color(0xFFFFF5F5), foregroundColor: const Color(0xFFE74C3C)),
        ),
      ],
    );
  }
}

class _Input extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;

  const _Input({required this.label, required this.controller, this.maxLines = 1, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label),
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEEEEEE), width: 2)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEEEEEE), width: 2)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE67E22), width: 2)),
  );
}
