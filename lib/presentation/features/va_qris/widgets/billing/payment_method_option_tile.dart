import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';

class PaymentMethodOptionTile extends StatelessWidget {
  const PaymentMethodOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.enabled = true,
    this.disabledReason,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  /// false = metode tidak boleh dipakai (mis. di luar batas nominal).
  final bool enabled;

  /// Alasan dari API, tampil di bawah deskripsi saat [enabled] false.
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: enabled ? 1 : 0.6, child: _buildTile());
  }

  Widget _buildTile() {
    return Material(
      color: enabled
          ? AppThemeColors.defaultSurface
          : AppThemeColors.defaultBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppThemeColors.defaultBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppThemeColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppThemeColors.brown, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppThemeColors.titleText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: AppThemeColors.secondaryText,
                      ),
                    ),
                    if (!enabled && disabledReason != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        disabledReason!,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          color: AppThemeColors.danger,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                enabled
                    ? Icons.chevron_right_rounded
                    : Icons.lock_outline_rounded,
                color: AppThemeColors.tertiaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
