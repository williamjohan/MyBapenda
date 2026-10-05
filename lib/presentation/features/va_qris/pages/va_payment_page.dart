import 'package:bapendacore/domain/entities/va_qris/payment_session_entity.dart';
import 'package:flutter/material.dart';
import '../widgets/payment/payment_guide_steps.dart';
import '../widgets/payment/payment_page_layout.dart';
import '../widgets/payment/va_number_card.dart';

/// Layar Virtual Account Bank Jatim.
class VaPaymentPage extends StatelessWidget {
  const VaPaymentPage({super.key, required this.session});

  final PaymentSessionEntity session;

  @override
  Widget build(BuildContext context) {
    return PaymentPageLayout(
      appBarTitle: 'Pembayaran VA Bank Jatim',
      session: session,
      shareLabel: 'Bagikan nomor VA',
      guideTitle: 'Cara membayar dengan VA',
      guideSteps: PaymentGuideSteps.va,
      cardBuilder: (context, session, isExpired, onRegenerate) => VaNumberCard(
        session: session,
        isExpired: isExpired,
        onRegenerate: onRegenerate,
      ),
    );
  }
}
