import 'package:mybapenda/domain/entities/va_qris/payment_session_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/theme_kit.dart';
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
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
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
                      color: palette.accentSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.account_balance_outlined,
                      size: 20,
                      color: palette.brandStrong,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Virtual Account Bank Jatim',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Nomor Virtual Account',
                style: TextStyle(fontSize: 12.5, color: palette.textSecondary),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _groupedVa,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: palette.brandStrong,
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
                    foregroundColor: palette.accent,
                    side: BorderSide(color: palette.brand),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: palette.border),
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
    final palette = context.palette;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(fontSize: 12.5, color: palette.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
