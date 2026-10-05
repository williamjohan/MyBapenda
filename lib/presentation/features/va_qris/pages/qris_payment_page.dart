import 'package:bapendacore/domain/entities/va_qris/payment_session_entity.dart';
import 'package:flutter/material.dart';
import '../widgets/payment/payment_guide_steps.dart';
import '../widgets/payment/payment_page_layout.dart';
import '../widgets/payment/qris_code_card.dart';

/// Layar QRIS yang di-scan wajib pajak.
class QrisPaymentPage extends StatelessWidget {
  const QrisPaymentPage({super.key, required this.session});

  final PaymentSessionEntity session;

  @override
  Widget build(BuildContext context) {
    return PaymentPageLayout(
      appBarTitle: 'Pembayaran QRIS',
      session: session,
      shareLabel: 'Bagikan QRIS',
      guideTitle: 'Cara membayar dengan QRIS',
      guideSteps: PaymentGuideSteps.qris,
      cardBuilder: (context, session, isExpired, onRegenerate) => QrisCodeCard(
        session: session,
        isExpired: isExpired,
        onRegenerate: onRegenerate,
      ),
    );
  }
}
