// lib/presentation/shared/widgets/bapenda_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum BapendaButtonVariant { primary, outlined }

class Button extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool iconAtEnd; 
  final BapendaButtonVariant variant;
  final bool isLoading;
  final bool expanded;
  final double height;

  const Button({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconAtEnd = false,
    this.variant = BapendaButtonVariant.primary,
    this.isLoading = false,
    this.expanded = true,
    this.height = 50,
  });

  static const Color _brand = Color(0xFFB8680F);

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == BapendaButtonVariant.primary;
    final fg = isPrimary ? Colors.white : _brand;
    final disabled = onPressed == null || isLoading;

    final textStyle = GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: fg,
    );

    final iconWidget = icon == null ? null : Icon(icon, size: 18, color: fg);

    final content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconWidget != null && !iconAtEnd) ...[
                iconWidget,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  style: textStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (iconWidget != null && iconAtEnd) ...[
                const SizedBox(width: 8),
                iconWidget,
              ],
            ],
          );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );

    final button = isPrimary
        ? ElevatedButton(
            onPressed: disabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _brand,
              disabledBackgroundColor: _brand.withValues(alpha: 0.5),
              elevation: 0,
              shape: shape,
            ),
            child: content,
          )
        : OutlinedButton(
            onPressed: disabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _brand.withValues(alpha: disabled ? 0.3 : 0.6),
              ),
              shape: shape,
            ),
            child: content,
          );

    return SizedBox(
      height: height,
      width: expanded ? double.infinity : null,
      child: button,
    );
  }
}
