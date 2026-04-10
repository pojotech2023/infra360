import 'package:flutter/material.dart';
import '../main.dart';

enum ToastType { success, error, warning, info }

class GlobalToast {
  static OverlayEntry? _overlayEntry;

  /// Safe version of show()
  /// Automatically ensures Overlay is available and prevents common timing errors.
  static void show({
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Remove any existing toast first
    _overlayEntry?.remove();

    // Safely get context from the global navigator key
    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint("⚠️ GlobalToast: navigatorKey context is null.");
      return;
    }

    // Delay execution to ensure Overlay is available after navigation changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(context, rootOverlay: true);
      if (overlay == null) {
        debugPrint("❌ GlobalToast: No Overlay found in the widget tree.");
        return;
      }

      final color = _getColor(type);
      final icon = _getIcon(type);

      _overlayEntry = OverlayEntry(
        builder: (_) => Positioned(
          top: 60,
          left: 20,
          right: 20,
          child: _ToastMessage(
            message: message,
            icon: icon,
            backgroundColor: color,
            duration: duration,
          ),
        ),
      );

      overlay.insert(_overlayEntry!);

      // Remove after duration
      Future.delayed(duration + const Duration(milliseconds: 300), () {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    });
  }

  // 🔹 Color mapping for toast types
  static Color _getColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Colors.green.shade600;
      case ToastType.error:
        return Colors.red.shade600;
      case ToastType.warning:
        return Colors.orange.shade700;
      case ToastType.info:
      default:
        return Colors.blue.shade600;
    }
  }

  // 🔹 Icon mapping for toast types
  static IconData _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.info:
      default:
        return Icons.info_outline;
    }
  }
}

class _ToastMessage extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Duration duration;

  const _ToastMessage({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.duration,
  });

  @override
  State<_ToastMessage> createState() => _ToastMessageState();
}

class _ToastMessageState extends State<_ToastMessage>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Smooth fade in/out animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _opacity = 1.0);
    });
    Future.delayed(widget.duration, () {
      if (mounted) setState(() => _opacity = 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
