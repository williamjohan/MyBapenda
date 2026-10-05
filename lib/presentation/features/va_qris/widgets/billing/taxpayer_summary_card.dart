import 'package:bapendacore/core/utils/app_formatters_utils.dart';
import 'package:bapendacore/domain/entities/va_qris/tax_billing_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors_new.dart';

class TaxpayerSummaryCard extends StatelessWidget {
  const TaxpayerSummaryCard({super.key, required this.billing});

  final TaxBillingEntity billing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.defaultSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      billing.taxpayerName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppThemeColors.titleText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppFormatters.nop(billing.nop),
                      style: const TextStyle(
                        fontSize: 13,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w600,
                        color: AppThemeColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppThemeColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  billing.taxType,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppThemeColors.brown,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppThemeColors.subtleBorder),
          ),
          _DetailLine(icon: Icons.storefront_outlined, text: billing.objectName),
          const SizedBox(height: 6),
          _DetailLine(icon: Icons.place_outlined, text: billing.address),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppThemeColors.tertiaryText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: AppThemeColors.secondaryText,
            ),
          ),
        ),
      ],
    );
  }
}
