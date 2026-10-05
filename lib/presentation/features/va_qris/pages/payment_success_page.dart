import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors_new.dart';
import '../../../../domain/entities/va_qris/payment_session_entity.dart';
import '../widgets/common/va_qris_primary_button.dart';
import '../widgets/payment/payment_receipt_card.dart';

/// Layar hasil setelah pembayaran berhasil.
///
/// TODO(tech-debt): dicapai lewat tombol simulasi. Nanti dipicu status paid
/// dari backend. Tambahkan juga aksi cetak/bagikan bukti bayar.
class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key, required this.session});

  final PaymentSessionEntity session;

  // TODO(tech-debt): ganti dengan navigasi eksplisit ke home (context.go).
  void _finish(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish(context);
      },
      child: Scaffold(
        backgroundColor: AppThemeColors.defaultBackground,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          color: AppThemeColors.successSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          size: 56,
                          color: AppThemeColors.success,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Pembayaran berhasil',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppThemeColors.titleText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Serahkan bukti bayar kepada wajib pajak.',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppThemeColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 24),
                      PaymentReceiptCard(session: session),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: VaQrisPrimaryButton(
                  label: 'Selesai',
                  onPressed: () => _finish(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
