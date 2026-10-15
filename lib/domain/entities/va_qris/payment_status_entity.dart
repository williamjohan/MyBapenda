import 'package:equatable/equatable.dart';

/// Status satu kode bayar dari API pembayaran.
class PaymentStatusEntity extends Equatable {
  const PaymentStatusEntity({
    required this.isPaid,
    this.paidAt,
    this.coreReference,
    this.amount,
  });

  final bool isPaid;
  final DateTime? paidAt;
  final String? coreReference;
  final int? amount;

  @override
  List<Object?> get props => [isPaid, paidAt, coreReference, amount];
}
