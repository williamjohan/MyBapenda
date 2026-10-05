import 'package:bapendacore/domain/entities/va_qris/payment_session_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/constants/app_colors_new.dart';
import 'payment_expired_overlay.dart';

class VaNumberCard extends StatelessWidget {
  const VaNumberCard({
    super.key,
    required this.session,
    required this.isExpired,
    required this.onRegenerate,
  });

  final PaymentSessionEntity session;
  final bool isExpired;
  final VoidCallback onRegenerate;

  String get _va => session.vaNumber ?? '';

  /// "7001123456789012" -> "7001 1234 5678 9012"
  String get _groupedVa {
    final buffer = StringBuffer();
    for (var i = 0; i < _va.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(_va[i]);
    }
    return buffer.toString();
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _va));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Nomor VA disalin')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: AppThemeColors.defaultSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeColors.subtleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppThemeColors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_outlined,
                      size: 20,
                      color: AppThemeColors.brown,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Virtual Account Bank Jatim',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppThemeColors.titleText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Nomor Virtual Account',
                style: TextStyle(fontSize: 12.5, color: AppThemeColors.secondaryText),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _groupedVa,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: AppThemeColors.brown,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isExpired ? null : () => _copy(context),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Salin nomor VA'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemeColors.gold,
                    side: const BorderSide(color: AppThemeColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: AppThemeColors.subtleBorder),
              ),
              const _InfoRow(label: 'Nama penerima', value: 'Bapenda Kota Surabaya'),
              const SizedBox(height: 8),
              _InfoRow(label: 'Referensi', value: session.reference),
            ],
          ),
          if (isExpired)
            Positioned.fill(
              child: PaymentExpiredOverlay(onRegenerate: onRegenerate),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: AppThemeColors.secondaryText),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppThemeColors.primaryText,
            ),
          ),
        ),
      ],
    );
  }
}
