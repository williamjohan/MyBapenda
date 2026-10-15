import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/pengiriman/antrean_entity.dart';

class AntreanPengirimanState extends Equatable {
  final RingkasanAntreanEntity ringkasan;
  final bool sedangKirim;

  const AntreanPengirimanState({
    this.ringkasan = const RingkasanAntreanEntity(),
    this.sedangKirim = false,
  });

  AntreanPengirimanState copyWith({
    RingkasanAntreanEntity? ringkasan,
    bool? sedangKirim,
  }) {
    return AntreanPengirimanState(
      ringkasan: ringkasan ?? this.ringkasan,
      sedangKirim: sedangKirim ?? this.sedangKirim,
    );
  }

  @override
  List<Object?> get props => [ringkasan, sedangKirim];
}
