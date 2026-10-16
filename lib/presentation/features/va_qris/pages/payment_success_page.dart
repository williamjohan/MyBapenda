import 'package:flutter/material.dart';
import '../../../../core/theme/theme_kit.dart';
import '../../../shared/widgets/theme_toggle_button.dart';
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
    final palette = context.palette;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish(context);
      },
      child: Scaffold(
        backgroundColor: palette.surfaceMuted,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                      child: Column(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: palette.successSoft,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 56,
                              color: palette.success,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Pembayaran berhasil',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Serahkan bukti bayar kepada wajib pajak.',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: palette.textSecondary,
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
              // Halaman ini tanpa app bar: tombol terang/gelap diberi latar
              // brand agar ikon putihnya tetap terlihat.
              Positioned(
                top: 8,
                right: 12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.brand,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const ThemeToggleButton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
