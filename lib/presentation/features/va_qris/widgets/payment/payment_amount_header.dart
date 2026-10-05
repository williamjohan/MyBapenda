import 'package:bapendacore/core/utils/app_formatters_utils.dart';
import 'package:bapendacore/core/utils/currency_formatter.dart';
import 'package:bapendacore/domain/entities/va_qris/payment_session_entity.dart';
import 'package:flutter/material.dart';

import '../common/va_qris_hero_header.dart';

class PaymentAmountHeader extends StatelessWidget {
  const PaymentAmountHeader({
    super.key,
    required this.session,
    required this.countdown,
  });

  final PaymentSessionEntity session;
  final Widget countdown;

  @override
  Widget build(BuildContext context) {
    return VaQrisHeroHeader(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
      child: Column(
        children: [
          Text(
            'Total pembayaran',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              CurrencyFormatter.toIdr(session.total),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            session.taxpayerName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            'NOP ${AppFormatters.nop(session.nop)}',
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 14),
          countdown,
        ],
      ),
    );
  }
}
