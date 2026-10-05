import 'package:bapendacore/domain/entities/va_qris/tax_period_entity.dart';
import 'payment_method.dart';

/// TODO(tech-debt): DUMMY ENTITY. Di versi final, [vaNumber], [qrisPayload]
/// dan [validFor] datang dari response backend/Bank Jatim, bukan dibuat lokal.
class PaymentSessionEntity {
  const PaymentSessionEntity({
    required this.reference,
    required this.method,
    required this.nop,
    required this.taxpayerName,
    required this.periods,
    required this.createdAt,
    required this.validFor,
    this.vaNumber,
    this.qrisPayload,
  });

  final String reference;
  final PaymentMethod method;
  final String nop;
  final String taxpayerName;
  final List<TaxPeriodEntity> periods;
  final DateTime createdAt;
  final Duration validFor;
  final String? vaNumber;
  final String? qrisPayload;

  int get principalTotal => periods.fold(0, (sum, p) => sum + p.principal);
  int get penaltyTotal => periods.fold(0, (sum, p) => sum + p.penalty);
  int get total => principalTotal + penaltyTotal;
}
