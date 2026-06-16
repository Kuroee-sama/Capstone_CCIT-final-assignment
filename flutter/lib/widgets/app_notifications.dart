import 'dart:async';
import 'package:flutter/material.dart';

enum AppNoticeType { success, error, warning, info }

class AppNotifier {
  static const Color _success = Color(0xFF27AE60);
  static const Color _error = Color(0xFFE74C3C);
  static const Color _warning = Color(0xFFE67E22);
  static const Color _info = Color(0xFF2196F3);
  static const Color _dark = Color(0xFF2D3436);

  static OverlayEntry? _activeToast;
  static Timer? _activeTimer;

  static void success(BuildContext context, String message, {String title = 'Berhasil'}) {
    _show(context, message, title: title, type: AppNoticeType.success);
  }

  static void error(BuildContext context, Object error, {String title = 'Gagal'}) {
    _show(context, _clean(error), title: title, type: AppNoticeType.error);
  }

  static void warning(BuildContext context, String message, {String title = 'Perhatian'}) {
    _show(context, message, title: title, type: AppNoticeType.warning);
  }

  static void info(BuildContext context, String message, {String title = 'Informasi'}) {
    _show(context, message, title: title, type: AppNoticeType.info);
  }

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Ya, lanjutkan',
    String cancelText = 'Batal',
    bool danger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: danger ? const Color(0xFFFFF5F5) : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(danger ? Icons.delete_outline : Icons.help_outline, color: danger ? _error : _warning, size: 30),
            ),
            const SizedBox(height: 18),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _dark)),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(color: Color(0xFF636E72), height: 1.45)),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF636E72),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(cancelText, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: danger ? _error : _dark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(confirmText, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return result == true;
  }

  static void _show(
    BuildContext context,
    String message, {
    required String title,
    required AppNoticeType type,
  }) {
    if (!context.mounted) return;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      _showSnackBarFallback(context, message, title: title, type: type);
      return;
    }

    _activeTimer?.cancel();
    _activeToast?.remove();
    _activeToast = null;

    final color = _color(type);
    final bg = _background(type);
    final icon = _icon(type);

    final entry = OverlayEntry(
      builder: (overlayContext) => Positioned(
        top: 14,
        left: 16,
        right: 16,
        child: SafeArea(
          child: IgnorePointer(
            ignoring: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Material(
                  color: Colors.transparent,
                  child: _ToastCard(
                    title: title,
                    message: message,
                    color: color,
                    bg: bg,
                    icon: icon,
                    onClose: _dismissToast,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _activeToast = entry;
    overlay.insert(entry);
    _activeTimer = Timer(const Duration(milliseconds: 3600), _dismissToast);
  }

  static void _dismissToast() {
    _activeTimer?.cancel();
    _activeTimer = null;
    _activeToast?.remove();
    _activeToast = null;
  }

  static void _showSnackBarFallback(
    BuildContext context,
    String message, {
    required String title,
    required AppNoticeType type,
  }) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final color = _color(type);
    final bg = _background(type);
    final icon = _icon(type);

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 3600),
        content: _ToastCard(
          title: title,
          message: message,
          color: color,
          bg: bg,
          icon: icon,
          onClose: messenger.hideCurrentSnackBar,
        ),
      ),
    );
  }

  static Color _color(AppNoticeType type) {
    switch (type) {
      case AppNoticeType.success:
        return _success;
      case AppNoticeType.error:
        return _error;
      case AppNoticeType.warning:
        return _warning;
      case AppNoticeType.info:
        return _info;
    }
  }

  static Color _background(AppNoticeType type) {
    switch (type) {
      case AppNoticeType.success:
        return const Color(0xFFEAFaf1);
      case AppNoticeType.error:
        return const Color(0xFFFFF5F5);
      case AppNoticeType.warning:
        return const Color(0xFFFFF3E0);
      case AppNoticeType.info:
        return const Color(0xFFE3F2FD);
    }
  }

  static IconData _icon(AppNoticeType type) {
    switch (type) {
      case AppNoticeType.success:
        return Icons.check_rounded;
      case AppNoticeType.error:
        return Icons.close_rounded;
      case AppNoticeType.warning:
        return Icons.priority_high_rounded;
      case AppNoticeType.info:
        return Icons.info_outline_rounded;
    }
  }

  static String _clean(Object error) => error.toString().replaceAll('Exception: ', '').trim();
}

class _ToastCard extends StatelessWidget {
  final String title;
  final String message;
  final Color color;
  final Color bg;
  final IconData icon;
  final VoidCallback onClose;

  const _ToastCard({
    required this.title,
    required this.message,
    required this.color,
    required this.bg,
    required this.icon,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F2F6)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .16), blurRadius: 30, offset: const Offset(0, 12))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 23),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppNotifier._dark, fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 3),
                  Text(message, style: const TextStyle(color: Color(0xFF636E72), height: 1.35, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onClose,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, size: 18, color: Color(0xFFB2BEC3)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
