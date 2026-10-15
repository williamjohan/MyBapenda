import 'package:equatable/equatable.dart';
import 'payment_method.dart';

/// Metode bayar yang boleh dipakai untuk suatu nominal. Batas nominal VA /
/// QRIS ditentukan API (setting server), bukan di aplikasi.
class PaymentNominalCheckEntity extends Equatable {
  const PaymentNominalCheckEntity({
    required this.vaAllowed,
    required this.vaMessage,
    required this.qrisAllowed,
    required this.qrisMessage,
  });

  final bool vaAllowed;
  final String vaMessage;
  final bool qrisAllowed;
  final String qrisMessage;

  bool isAllowed(PaymentMethod method) =>
      method == PaymentMethod.qris ? qrisAllowed : vaAllowed;

  String messageFor(PaymentMethod method) =>
      method == PaymentMethod.qris ? qrisMessage : vaMessage;

  @override
  List<Object?> get props => [vaAllowed, vaMessage, qrisAllowed, qrisMessage];
}
