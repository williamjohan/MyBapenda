import 'package:equatable/equatable.dart';

/// Cara serah sesuai id master (`caraSerah` di `POST serah`).
enum CaraSerah {
  langsung(1, 'Langsung'),
  dititipkan(2, 'Dititipkan'),
  ditempel(3, 'Ditempel');

  final int id;
  final String label;
  const CaraSerah(this.id, this.label);

  static CaraSerah? fromId(int? id) {
    for (final c in CaraSerah.values) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Langsung/Dititipkan: wajib nama penerima, hubungan, foto serah & TTD.
  bool get butuhPenerima => this != CaraSerah.ditempel;
}

/// Satu opsi dropdown dari `GET master`.
class OpsiMasterEntity extends Equatable {
  final int id;
  final String nama;
  final bool wajibKeterangan;

  const OpsiMasterEntity({
    required this.id,
    required this.nama,
    this.wajibKeterangan = false,
  });

  @override
  List<Object?> get props => [id, nama, wajibKeterangan];
}

class MasterPengirimanEntity extends Equatable {
  final List<OpsiMasterEntity> hubunganPenerima;
  final List<OpsiMasterEntity> alasanGagal;
  final List<OpsiMasterEntity> caraSerah;

  const MasterPengirimanEntity({
    this.hubunganPenerima = const [],
    this.alasanGagal = const [],
    this.caraSerah = const [],
  });

  @override
  List<Object?> get props => [hubunganPenerima, alasanGagal, caraSerah];
}
