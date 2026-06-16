import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/menu_model.dart';

/// Menampilkan gambar menu dari database.
/// Nilai kolom `menu.gambar` boleh berupa:
/// - nama file saja, contoh: 1772350960_xxx.jpeg
/// - path relatif, contoh: uploads/menu/1772350960_xxx.jpeg
/// - URL penuh, contoh: http://localhost:8080/uploads/menu/xxx.jpeg
class MenuImage extends StatelessWidget {
  final MenuModel menu;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;

  const MenuImage({
    super.key,
    required this.menu,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiConfig.menuImageUrl(menu.gambar);

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: width,
        height: height,
        color: const Color(0xFFFFF3E0),
        child: imageUrl == null
            ? const _MenuImageFallback()
            : Image.network(
                imageUrl,
                width: width,
                height: height,
                fit: fit,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE67E22)),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => const _MenuImageFallback(),
              ),
      ),
    );
  }
}

class _MenuImageFallback extends StatelessWidget {
  const _MenuImageFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.restaurant_menu, size: 28, color: Color(0xFFE67E22)),
    );
  }
}
